import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct PlayView: View {
    @EnvironmentObject private var audioManager: AudioManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                // 背景图片和毛玻璃效果
                if let artwork = audioManager.currentAudio?.artwork {
                    Image(uiImage: artwork)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .edgesIgnoringSafeArea(.all)
                        // .position(x: geometry.size.width/2, y: geometry.size.height/2)
                        .blur(radius: 10)
//                        .opacity(0.6)
                    
                    // 添加渐变叠加层增强视觉效果
                    LinearGradient(
                        gradient: Gradient(colors: [Color.black.opacity(0.3), Color.black.opacity(0.7)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                } else {
                    // 无封面时的默认背景
                    LinearGradient(gradient: Gradient(colors: [Color(hex: "#4A4A4A"), Color.black]),
                                   startPoint: .top,
                                   endPoint: .bottom)
                        .ignoresSafeArea()
                }
            }
            VStack(spacing: 20) {
                // 顶部导航栏
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.down")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                        
                    Spacer()
                        
                    Text("正在播放")
                        .font(.headline)
                        .foregroundColor(.white)
                        
                    Spacer()
                        
                    Button(action: {}) {
                        Image(systemName: "ellipsis")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal)
                    
                Spacer()
                    
                // 封面图片
                Group {
                    if let artwork = audioManager.currentAudio?.artwork {
                        Image(uiImage: artwork)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else {
                        Image(systemName: "music.note")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.gray)
                    }
                }
                .frame(width: 300, height: 300)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(radius: 10)
                    
                // 歌曲信息
                VStack(spacing: 8) {
                    Text(audioManager.currentAudio?.title ?? audioManager.currentAudio?.filename ?? "未知歌曲")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .lineLimit(1)
                        
                    Text(audioManager.currentAudio?.artist ?? "未知艺术家")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                        
                    Text(audioManager.currentAudio?.album ?? "未知专辑")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                .padding(.top, 30)
                    
                Spacer()
                    
                // 播放进度
                VStack(spacing: 10) {
                    Slider(value: $audioManager.currentTime, in: 0 ... audioManager.duration) { editing in
                        if !editing {
                            audioManager.seek(to: audioManager.currentTime)
                        }
                    }
                    .accentColor(.white)
                        
                    HStack {
                        Text(formatTime(audioManager.currentTime))
                        Spacer()
                        Text(formatTime(audioManager.duration))
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                }
                .padding(.horizontal)
                    
                // 播放控制
                HStack(spacing: 40) {
                    Button(action: { audioManager.togglePlayMode() }) {
                        Image(systemName: audioManager.isShuffleMode ? "shuffle" : (audioManager.repeatMode == .one ? "repeat.1" : "repeat"))
                            .font(.title2)
                            .foregroundColor(audioManager.isShuffleMode || audioManager.repeatMode != .off ? .green : .white)
                    }
                        
                    Button(action: { audioManager.playPrevious() }) {
                        Image(systemName: "backward.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                        
                    Button(action: { audioManager.togglePlayPause() }) {
                        Image(systemName: audioManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 70))
                            .foregroundColor(.white)
                    }
                        
                    Button(action: { audioManager.playNext() }) {
                        Image(systemName: "forward.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                        
                    Button(action: {}) {
                        Image(systemName: "list.bullet")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
                .padding()
                    
                Spacer()
            }
        }
    }
}

func formatTime(_ time: TimeInterval) -> String {
    let minutes = Int(time) / 60
    let seconds = Int(time) % 60
    return String(format: "%d:%02d", minutes, seconds)
}

#Preview {
    PlayView()
        .preferredColorScheme(.dark)
}
