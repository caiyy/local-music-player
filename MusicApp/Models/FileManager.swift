import Foundation

class MusicFileManager {
    static let shared = MusicFileManager()
    private let fileManager = FileManager.default
    
    private init() {}
    
    // 获取Documents目录路径
    private var documentsPath: String? {
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?.path
    }
    
    // 支持的音频文件扩展名
    private let supportedExtensions = ["mp3", "wav", "m4a", "aac", "flac", "ogg"]
    
    // 扫描音频文件
    func scanAudioFiles() -> [URL] {
        guard let documentsPath = documentsPath else {
            print("⚠️ 无法访问Documents目录")
            return []
        }
        
        var audioURLs: [URL] = []
        
        func scanDirectory(_ path: String) {
            do {
                let items = try fileManager.contentsOfDirectory(atPath: path)
                
                for item in items {
                    let itemPath = (path as NSString).appendingPathComponent(item)
                    var isDirectory: ObjCBool = false
                    
                    if fileManager.fileExists(atPath: itemPath, isDirectory: &isDirectory) {
                        if isDirectory.boolValue {
                            // 递归扫描子目录
                            scanDirectory(itemPath)
                        } else {
                            // 检查是否为音频文件
                            let fileExtension = (item as NSString).pathExtension.lowercased()
                            if supportedExtensions.contains(fileExtension) {
                                let url = URL(fileURLWithPath: itemPath)
                                audioURLs.append(url)
                                print("   📄 \(itemPath)")
                            }
                        }
                    }
                }
            } catch {
                print("❌ 扫描目录时出错: \(path) - \(error.localizedDescription)")
            }
        }
        
        print("📂 开始递归扫描目录: \(documentsPath)")
        scanDirectory(documentsPath)
        print("✅ 找到\(audioURLs.count)个音频文件")
        
        return audioURLs
    }
    
    // 监听文件变化
    func startMonitoring() {
        // 这里可以添加文件系统监控的实现
        // 由于iOS的限制，我们可能需要依赖于应用生命周期事件来触发扫描
        print("🔍 开始监控文件变化")
    }
}