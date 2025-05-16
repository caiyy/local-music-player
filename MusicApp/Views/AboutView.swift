import SwiftUI

struct AboutView: View {
    @EnvironmentObject private var audioManager: AudioManager
    
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
                        .blur(radius: 10)
                    
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
                List {
                    Section {
                        VStack(spacing: 15) {
                            Image(systemName: "music.note.list")
                                .font(.system(size: 60))
                                .foregroundColor(.purple)
                            
                            Text("音乐播放器")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("版本 1.0.0")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical)
                        .listRowBackground(Color.black.opacity(0.3))
                    }
                    
                    Section(header: Text("功能特点").foregroundColor(.white)) {
                        AboutRowView(icon: "music.note", title: "本地音乐播放", description: "支持多种音频格式")
                        AboutRowView(icon: "slider.horizontal.3", title: "均衡器", description: "自定义音频效果")
                        AboutRowView(icon: "speaker.wave.3", title: "高品质音频", description: "支持无损音质播放")
                        AboutRowView(icon: "person.crop.circle", title: "个性化设置", description: "定制您的音乐体验")
                    }
                    
                    Section(header: Text("联系我们").foregroundColor(.white)) {
                        Button(action: {
                            // TODO: 实现反馈功能
                        }) {
                            HStack {
                                Image(systemName: "envelope")
                                    .foregroundColor(.blue)
                                Text("反馈建议")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                        .listRowBackground(Color.black.opacity(0.3))
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("关于")
            .navigationBarTitleDisplayMode(.inline)
            .foregroundColor(.white)
        }
    }
}

struct AboutRowView: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
        .listRowBackground(Color.black.opacity(0.3))
    }
}

#Preview {
    NavigationView {
        AboutView()
            .environmentObject(AudioManager.shared)
            .preferredColorScheme(.dark)
    }
}