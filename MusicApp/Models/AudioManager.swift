import Foundation
import AVFoundation

class AudioManager: NSObject, ObservableObject {
    static let shared = AudioManager()
    private let fileManager = MusicFileManager.shared
    
    // 音频播放器
    private var audioPlayer: AVAudioPlayer?
    
    // 发布的状态
    @Published var audioFiles: [AudioFile] = []
    @Published var currentAudio: AudioFile?
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var isShuffleMode = false
    @Published var repeatMode = RepeatMode.off
    
    // 播放模式
    enum RepeatMode {
        case off
        case all
        case one
    }
    
    private override init() {
        super.init()
        setupNotifications()
        Task {
            await setupAudioSession()
            // 先加载音频文件列表
            await loadAudioFiles()
            // 再恢复播放状态
            PlaybackStateManager.shared.restorePlaybackState(self)
        }
    }
    
    // 加载音频文件
    func loadAudioFiles() async {
        let urls = fileManager.scanAudioFiles()
        audioFiles = await withTaskGroup(of: AudioFile.self) { group in
            for url in urls {
                group.addTask {
                    await AudioFile.create(from: url)
                }
            }
            var loadedFiles: [AudioFile] = []
            for await file in group {
                loadedFiles.append(file)
            }
            return loadedFiles
        }
        
        // 如果没有正在播放的音频且有音频文件，则播放第一首
        if currentAudio == nil, let firstAudio = audioFiles.first {
            play(firstAudio)
        }
    }
    
    // 刷新音频文件列表
    func refreshAudioFiles() async {
        print("🔄 刷新音频文件列表")
        await loadAudioFiles()
    }
    
    // 设置音频会话
    private func setupAudioSession() async {
        await AudioMetadataManager.shared.configureBackgroundPlayback()
    }
    
    // 设置通知监听
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self,
            selector: #selector(handlePlayPauseCommand),
            name: .audioManagerPlayPauseNotification,
            object: nil)
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(handleNextTrackCommand),
            name: .audioManagerNextTrackNotification,
            object: nil)
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(handlePreviousTrackCommand),
            name: .audioManagerPreviousTrackNotification,
            object: nil)
            
        NotificationCenter.default.addObserver(self,
            selector: #selector(handleSeekCommand(_:)),
            name: .audioManagerSeekNotification,
            object: nil)
    }
    
    // 处理远程控制命令
    @objc private func handlePlayPauseCommand() {
        togglePlayPause()
    }
    
    @objc private func handleNextTrackCommand() {
        playNext()
    }
    
    @objc private func handlePreviousTrackCommand() {
        playPrevious()
    }
    
    // 处理进度条控制命令
    @objc private func handleSeekCommand(_ notification: Notification) {
        if let time = notification.userInfo?["time"] as? TimeInterval {
            seek(to: time)
        }
    }
    
    // 播放音频
    func play(_ audio: AudioFile) {
        guard audio.url != currentAudio?.url else {
            togglePlayPause()
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audio.url)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            currentAudio = audio
            isPlaying = true
            duration = audioPlayer?.duration ?? 0
            startTimeObserver()
            // 保存播放状态
            PlaybackStateManager.shared.savePlaybackState(self)
        } catch {
            print("❌ 播放音频失败: \(error.localizedDescription)")
        }
    }
    
    // 切换播放/暂停
    func togglePlayPause() {
        if isPlaying {
            audioPlayer?.pause()
        } else {
            audioPlayer?.play()
        }
        isPlaying.toggle()
        // 保存播放状态
        PlaybackStateManager.shared.savePlaybackState(self)
    }
    
    // 播放下一首
    func playNext() {
        guard let currentIndex = getCurrentIndex() else { return }
        var nextIndex = currentIndex + 1
        
        if isShuffleMode {
            nextIndex = Int.random(in: 0..<audioFiles.count)
        } else if nextIndex >= audioFiles.count {
            nextIndex = 0
        }
        
        play(audioFiles[nextIndex])
    }
    
    // 播放上一首
    func playPrevious() {
        guard let currentIndex = getCurrentIndex() else { return }
        var previousIndex = currentIndex - 1
        
        if previousIndex < 0 {
            previousIndex = audioFiles.count - 1
        }
        
        play(audioFiles[previousIndex])
    }
    
    // 切换随机播放模式
    func toggleShuffleMode() {
        isShuffleMode.toggle()
    }
    
    // 切换循环播放模式
    func toggleRepeatMode() {
        switch repeatMode {
        case .off:
            repeatMode = .all
        case .all:
            repeatMode = .one
        case .one:
            repeatMode = .off
        }
    }
    
    // 切换播放模式（随机/循环）
    func togglePlayMode() {
        if isShuffleMode {
            isShuffleMode = false
            toggleRepeatMode()
        } else if repeatMode == .off {
            repeatMode = .all
        } else if repeatMode == .all {
            repeatMode = .one
        } else {
            repeatMode = .off
            isShuffleMode = true
        }
    }
    
    // 设置播放进度
    func seek(to time: TimeInterval) {
        audioPlayer?.currentTime = time
        currentTime = time
    }
    
    // 获取当前音频在列表中的索引
    private func getCurrentIndex() -> Int? {
        guard let currentAudio = currentAudio else { return nil }
        return audioFiles.firstIndex { $0.url == currentAudio.url }
    }
    
    // 开始时间观察器
    private func startTimeObserver() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] timer in
            guard let self = self, let player = self.audioPlayer else {
                timer.invalidate()
                return
            }
            self.currentTime = player.currentTime
            
            // 更新锁屏界面信息
            if let currentAudio = self.currentAudio {
                AudioMetadataManager.shared.updateNowPlayingInfo(
                    title: currentAudio.title ?? currentAudio.filename,
                    artist: currentAudio.artist,
                    album: currentAudio.album,
                    duration: self.duration,
                    currentTime: self.currentTime,
                    isPlaying: self.isPlaying,
                    artwork: currentAudio.artwork
                )
            }
        }
    }
}

// MARK: - AVAudioPlayerDelegate
extension AudioManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            switch repeatMode {
            case .off:
                if !isShuffleMode {
                    isPlaying = false
                } else {
                    playNext()
                }
            case .one:
                player.play()
            case .all:
                playNext()
            }
        }
    }
}
