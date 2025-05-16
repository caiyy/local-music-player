import Foundation

struct PlaybackState: Codable {
    var currentAudioURL: URL?
    var currentTime: TimeInterval
    var isPlaying: Bool
    var isShuffleMode: Bool
    var repeatMode: Int // 0: off, 1: all, 2: one
    
    init(currentAudioURL: URL? = nil, currentTime: TimeInterval = 0, isPlaying: Bool = false, isShuffleMode: Bool = false, repeatMode: Int = 0) {
        self.currentAudioURL = currentAudioURL
        self.currentTime = currentTime
        self.isPlaying = isPlaying
        self.isShuffleMode = isShuffleMode
        self.repeatMode = repeatMode
    }
}