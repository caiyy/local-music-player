import SwiftUI

struct PlaylistView: View {
    @EnvironmentObject private var audioManager: AudioManager
    @State private var showPlayView = false
    
    var body: some View {
        NavigationView {
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
                
                ScrollView {
                VStack(spacing: 20) {
                    // 音频文件列表
                    VStack(alignment: .leading, spacing: 10) {
                        Text("音频列表")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(audioManager.audioFiles, id: \.url) { audio in
                            Button(action: { audioManager.play(audio) }) {
                                HStack {
                                    if let artwork = audio.artwork {
                                        Image(uiImage: artwork)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 60, height: 60)
                                            .cornerRadius(12)
                                    } else {
                                        Image(systemName: "music.note")
                                            .resizable()
                                            .frame(width: 60, height: 60)
                                            .cornerRadius(12)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(audio.title ?? audio.filename)
                                            .font(.headline)
                                        Text(audio.artist ?? "未知艺术家")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        Text(audio.album ?? "未知专辑")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: audioManager.currentAudio?.url == audio.url && audioManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                        .font(.title)
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                            .foregroundColor(.primary)
                            .background(audioManager.currentAudio?.url == audio.url ? Color.white.opacity(0.2) : Color.clear)
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("音乐列表")
            }
            
            // 底部播放控制栏
            VStack {
                Spacer()
                
                HStack {
                    Button(action: { showPlayView = true }) {
                        HStack {
                            if let artwork = audioManager.currentAudio?.artwork {
                                Image(uiImage: artwork)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 40, height: 40)
                                    .cornerRadius(5)
                            } else {
                                Image(systemName: "music.note")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .cornerRadius(5)
                                    .foregroundColor(.gray)
                            }
                            
                            VStack(alignment: .leading) {
                                Text(audioManager.currentAudio?.title ?? audioManager.currentAudio?.filename ?? "未知歌曲")
                                    .font(.subheadline)
                                Text(audioManager.currentAudio?.artist ?? "未知艺术家")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button(action: { audioManager.togglePlayPause() }) {
                        Image(systemName: audioManager.isPlaying ? "pause.fill" : "play.fill")
                            .foregroundColor(.white)
                    }
                    
                    Button(action: { audioManager.playNext() }) {
                        Image(systemName: "forward.fill")
                            .foregroundColor(.white)
                    }
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .sheet(isPresented: $showPlayView) {
                    PlayView()
                }
            }
        }
    }
}

#Preview {
    PlaylistView()
        .preferredColorScheme(.dark)
}