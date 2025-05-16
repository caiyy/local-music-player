import Foundation

class PlaybackStateManager {
    static let shared = PlaybackStateManager()
    private let defaults = UserDefaults.standard
    private let playbackStateKey = "playbackState"
    
    private init() {}
    
    // 保存播放状态
    func savePlaybackState(_ audioManager: AudioManager) {
        let state = PlaybackState(
            currentAudioURL: audioManager.currentAudio?.url,
            currentTime: audioManager.currentTime,
            isPlaying: audioManager.isPlaying,
            isShuffleMode: audioManager.isShuffleMode,
            repeatMode: audioManager.repeatMode == .off ? 0 : (audioManager.repeatMode == .all ? 1 : 2)
        )
        
        if let encoded = try? JSONEncoder().encode(state) {
            defaults.set(encoded, forKey: playbackStateKey)
        }
    }
    
    // 恢复播放状态
    func restorePlaybackState(_ audioManager: AudioManager) {
        guard let data = defaults.data(forKey: playbackStateKey),
              let state = try? JSONDecoder().decode(PlaybackState.self, from: data) else {
            return
        }
        
        // 恢复播放模式
        audioManager.isShuffleMode = state.isShuffleMode
        switch state.repeatMode {
        case 0: audioManager.repeatMode = .off
        case 1: audioManager.repeatMode = .all
        case 2: audioManager.repeatMode = .one
        default: break
        }
        
        // 恢复当前音频和播放进度
        if let url = state.currentAudioURL,
           let audio = audioManager.audioFiles.first(where: { $0.url == url }) {
            audioManager.play(audio)
            audioManager.seek(to: state.currentTime)
            if !state.isPlaying {
                audioManager.togglePlayPause()
            }
        }
    }
}