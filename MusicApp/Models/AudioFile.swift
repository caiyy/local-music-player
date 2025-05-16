import Foundation
import UIKit

class AudioFile: Identifiable, ObservableObject {
    let id = UUID()
    let url: URL
    let filename: String
    let fileExtension: String
    
    // 音频文件的元数据信息
    @Published var title: String?
    @Published var artist: String?
    @Published var album: String?
    @Published var duration: TimeInterval?
    @Published var artwork: UIImage?
    
    private init(url: URL) {
        self.url = url
        self.filename = url.deletingPathExtension().lastPathComponent
        self.fileExtension = url.pathExtension
    }
    
    // 从URL创建AudioFile实例
    @MainActor
    static func create(from url: URL) async -> AudioFile {
        let audioFile = AudioFile(url: url)
        
        // 使用AudioMetadataManager提取元数据
        let metadataManager = AudioMetadataManager.shared
        let metadata = await metadataManager.extractMetadata(from: url)
        
        // 提取封面图片，优先使用FLAC元数据中的封面图片
        let artwork = await metadataManager.extractArtwork(from: url, flacArtwork: metadata.flacArtwork)
        
        // Dispatch UI updates to the main thread
        await MainActor.run {
            audioFile.title = metadata.title
            audioFile.artist = metadata.artist
            audioFile.album = metadata.album
            audioFile.duration = metadata.duration
            audioFile.artwork = artwork
        }
        
        return audioFile
    }
}
