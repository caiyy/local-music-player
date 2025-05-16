import Foundation
import AVFoundation
import MediaPlayer
import FLACMetadataKit

@MainActor
class AudioMetadataManager {
    static let shared = AudioMetadataManager()
    
    private init() {}
    
    // 提取音频文件的元数据
    func extractMetadata(from url: URL) async -> (title: String?, artist: String?, album: String?, duration: TimeInterval?, flacArtwork: UIImage?) {
        let asset = AVAsset(url: url)
        var title: String?
        var artist: String?
        var album: String?
        var duration: TimeInterval?
        var flacArtwork: UIImage? = nil
        
        // 从FLAC文件中提取元数据
        // 判断是否是flac文件
        if url.pathExtension == "flac" {
            do {
                let fileData = try Data(contentsOf: URL(fileURLWithPath: url.path))
                let parser = FLACParser(data: fileData)
                let metadata = try parser.parse()
                if let vorbisComments = metadata.vorbisComments {
                    title = vorbisComments.metadata[.title]
                    artist = vorbisComments.metadata[.artist]
                    album = vorbisComments.metadata[.album]
                    print("FLAC metadata: \(title), \(artist), \(album)")
                }
                
                // 从FLAC元数据中提取封面图片
                if let picture = metadata.picture,
                   let image = UIImage(data: picture.data) {
                    print("FLAC artwork: \(image)")
                    flacArtwork = image
                }
            } catch {
                // 如果FLAC解析失败，继续使用AVAsset解析
                print("FLAC parsing failed, falling back to AVAsset")
            }
        }

        // 获取时长
        duration = CMTimeGetSeconds(asset.duration)
        
        // 获取元数据
        let metadata = asset.metadata
        
        for item in metadata {
            if let key = item.commonKey?.rawValue {
                switch key {
                case "title":
                    title = try? await item.load(.value) as? String
                case "artist":
                    artist = try? await item.load(.value) as? String
                case "albumName":
                    album = try? await item.load(.value) as? String
                default:
                    break
                }
            } else if let keySpace = item.keySpace, let keyName = item.key?.description {
                switch keySpace.rawValue {
                case "org.id3":
                    switch keyName {
                    case "TIT2": // 标题
                        title = try? await item.load(.value) as? String
                    case "TPE1": // 艺术家
                        artist = try? await item.load(.value) as? String
                    case "TALB": // 专辑
                        album = try? await item.load(.value) as? String
                    default:
                        break
                    }
                case "org.xiph.flac":
                    switch keyName {
                    case "TITLE":
                        title = try? await item.load(.value) as? String
                    case "ARTIST":
                        artist = try? await item.load(.value) as? String
                    case "ALBUM":
                        album = try? await item.load(.value) as? String
                    default:
                        break
                    }
                default:
                    break
                }
            }
        }
        
        // 如果无法从元数据获取标题，使用文件名
        if title == nil {
            title = url.deletingPathExtension().lastPathComponent
        }
        
        return (title, artist, album, duration, flacArtwork)
    }
    
        // 配置后台播放
    func configureBackgroundPlayback() async {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            
            // 配置远程控制和锁屏信息
            setupRemoteTransportControls()
            
            print("✅ 后台播放配置成功")
        } catch {
            print("❌ 后台播放配置失败: \(error.localizedDescription)")
        }
    }
    
    // 设置远程控制和锁屏信息
    private func setupRemoteTransportControls() {
        // 获取远程控制中心
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // 配置播放命令
        commandCenter.playCommand.addTarget { [weak self] event in
            NotificationCenter.default.post(name: .audioManagerPlayPauseNotification, object: nil)
            return .success
        }
        
        // 配置暂停命令
        commandCenter.pauseCommand.addTarget { [weak self] event in
            NotificationCenter.default.post(name: .audioManagerPlayPauseNotification, object: nil)
            return .success
        }
        
        // 配置下一曲命令
        commandCenter.nextTrackCommand.addTarget { [weak self] event in
            NotificationCenter.default.post(name: .audioManagerNextTrackNotification, object: nil)
            return .success
        }
        
        // 配置上一曲命令
        commandCenter.previousTrackCommand.addTarget { [weak self] event in
            NotificationCenter.default.post(name: .audioManagerPreviousTrackNotification, object: nil)
            return .success
        }
        
        // 配置进度条控制
        commandCenter.changePlaybackPositionCommand.isEnabled = true
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            if let event = event as? MPChangePlaybackPositionCommandEvent {
                NotificationCenter.default.post(
                    name: .audioManagerSeekNotification,
                    object: nil,
                    userInfo: ["time": event.positionTime]
                )
            }
            return .success
        }
    }
    
    // 提取音频文件的封面图
    func extractArtwork(from url: URL, flacArtwork: UIImage? = nil) async -> UIImage? {
        // 如果已经有FLAC封面图片，直接返回
        if let flacArtwork = flacArtwork {
            return flacArtwork
        }
        
        let asset = AVAsset(url: url)
        var artwork: UIImage?
        
        // 从元数据中提取封面图
        for item in asset.metadata {
            // 尝试从通用键中获取封面图
            if let key = item.commonKey?.rawValue,
               (key == "artwork" || key == "artworkData" || key == "coverArt"),
               let imageData = try? await item.load(.value) as? Data,
               let image = UIImage(data: imageData) {
                artwork = image
                break
            }
            
            // 处理特定格式的元数据
            if let keySpace = item.keySpace,
               let keyName = item.key?.description {
                switch keySpace.rawValue {
                case "org.id3":
                    // 处理ID3标签 (MP3)
                    if (keyName == "APIC" || keyName == "PIC"),
                       let imageData = try? await item.load(.value) as? Data,
                       let image = UIImage(data: imageData) {
                        artwork = image
                        break
                    }
                case "com.apple.iTunes":
                    // 处理iTunes标签 (M4A, AAC)
                    if let imageData = item.value as? Data,
                       let image = UIImage(data: imageData) {
                        artwork = image
                        break
                    }
                case "org.xiph.flac":
                    // 处理FLAC标签
                    if (keyName == "METADATA_BLOCK_PICTURE" || keyName == "PICTURE"),
                       let imageData = try? await item.load(.value) as? Data,
                       let image = UIImage(data: imageData) {
                        artwork = image
                        break
                    }
                case "org.mp4":
                    // 处理MP4标签
                    if (keyName == "covr" || keyName == "cover"),
                       let imageData = try? await item.load(.value) as? Data,
                       let image = UIImage(data: imageData) {
                        artwork = image
                        break
                    }
                default:
                    // 尝试直接从值中提取图片数据
                    if let imageData = item.value as? Data,
                       let image = UIImage(data: imageData) {
                        artwork = image
                        break
                    }
                }
            }
        }
        
        return artwork
    }
    
    // 更新锁屏界面信息
    func updateNowPlayingInfo(title: String, artist: String?, album: String?, duration: TimeInterval, currentTime: TimeInterval, isPlaying: Bool, artwork: UIImage? = nil) {
        var nowPlayingInfo = [String: Any]()
        
        // 设置音乐信息
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        nowPlayingInfo[MPMediaItemPropertyArtist] = artist ?? "未知艺术家"
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = album ?? "未知专辑"
        
        // 设置时间信息
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        
        // 设置播放速率
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        
        // 设置封面图
        if let artwork = artwork {
            let albumArt = MPMediaItemArtwork(boundsSize: artwork.size) { size in
                return artwork
            }
            nowPlayingInfo[MPMediaItemPropertyArtwork] = albumArt
        }
        
        // 更新锁屏界面
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let audioManagerPlayPauseNotification = Notification.Name("AudioManagerPlayPauseNotification")
    static let audioManagerNextTrackNotification = Notification.Name("AudioManagerNextTrackNotification")
    static let audioManagerPreviousTrackNotification = Notification.Name("AudioManagerPreviousTrackNotification")
    static let audioManagerSeekNotification = Notification.Name("AudioManagerSeekNotification")
}
