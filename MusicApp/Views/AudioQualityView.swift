import SwiftUI

struct AudioQualityView: View {
    @EnvironmentObject private var audioManager: AudioManager
    @State private var selectedQuality = 1
    
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
                    Section(header: Text("音质设置").foregroundColor(.white)) {
                        Picker("音质", selection: $selectedQuality) {
                            Text("标准 (128kbps)").tag(0)
                            Text("高品质 (320kbps)").tag(1)
                            Text("无损 (FLAC)").tag(2)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .listRowBackground(Color.black.opacity(0.3))
                        
                        HStack {
                            Text("当前音质")
                            Spacer()
                            Text(selectedQuality == 0 ? "标准" : (selectedQuality == 1 ? "高品质" : "无损"))
                                .foregroundColor(.gray)
                        }
                        .listRowBackground(Color.black.opacity(0.3))
                    }
                    
                    Section(header: Text("说明").foregroundColor(.white)) {
                        Text("更高的音质需要更多的存储空间和带宽。建议在WiFi环境下使用高品质或无损音质。")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .listRowBackground(Color.black.opacity(0.3))
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("音质")
            .navigationBarTitleDisplayMode(.inline)
            .foregroundColor(.white)
        }
    }
}

#Preview {
    NavigationView {
        AudioQualityView()
            .environmentObject(AudioManager.shared)
            .preferredColorScheme(.dark)
    }
}