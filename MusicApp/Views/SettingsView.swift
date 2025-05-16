import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var audioManager: AudioManager
    @State private var isHighQualityEnabled = true
    @State private var isWifiOnlyEnabled = true
    @State private var isAutoUpdateEnabled = true
    @State private var isUpdating = false
    
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
                
                List {                    
                    Group {
                    // 用户信息
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.gray)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("音乐爱好者")
                                .font(.headline)
                            Text("查看个人资料")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 8)
                    .listRowBackground(Color.black.opacity(0.3))
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // 音频设置
                Section(header: Text("音频设置").foregroundColor(.white)) {
                    // 设置Section的背景为半透明黑色
                    NavigationLink(destination: AudioQualityView()) {
                        HStack {
                            Image(systemName: "speaker.wave.3.fill")
                                .foregroundColor(.purple)
                            Text("音质")
                        }
                    }
                    .listRowBackground(Color.black.opacity(0.3))
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    
                    NavigationLink(destination: EqualizerView()) {
                        HStack {
                            Image(systemName: "slider.horizontal.3")
                                .foregroundColor(.blue)
                            Text("均衡器")
                        }
                    }
                    .listRowBackground(Color.black.opacity(0.3))
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                }
                
                // 下载设置
                Section(header: Text("下载设置").foregroundColor(.white)) {
                    // 设置Section的背景为半透明黑色
                    Toggle(isOn: $isHighQualityEnabled) {
                        HStack {
                            Image(systemName: "arrow.down.circle.fill")
                                .foregroundColor(.green)
                            Text("音质标准化")
                        }
                    }
                    .listRowBackground(Color.black.opacity(0.3))
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    
                    Toggle(isOn: $isWifiOnlyEnabled) {
                        HStack {
                            Image(systemName: "wifi")
                                .foregroundColor(.blue)
                            Text("仅在WiFi下下载")
                        }
                    }
                    .listRowBackground(Color.black.opacity(0.3))
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    
                    Toggle(isOn: $isAutoUpdateEnabled) {
                        HStack {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .foregroundColor(.orange)
                            Text("自动更新列表")
                        }
                    }
                    .listRowBackground(Color.black.opacity(0.3))
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    
                    Button(action: {
                        isUpdating = true
                        Task {
                            await audioManager.refreshAudioFiles()
                            isUpdating = false
                        }
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(.blue)
                            Text("手动更新列表")
                            if isUpdating {
                                Spacer()
                                ProgressView()
                            }
                        }
                    }
                    .disabled(isUpdating)
                    .listRowBackground(Color.black.opacity(0.3))
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                }
                
                // 其他设置
                Section(header: Text("其他").foregroundColor(.white)) {
                    // 设置Section的背景为半透明黑色
                    NavigationLink(destination: AboutView()) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.gray)
                            Text("关于")
                        }
                    }
                    .listRowBackground(Color.black.opacity(0.3))
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                }
            }
            .navigationTitle("设置")
            .foregroundColor(.white)
            .listStyle(InsetGroupedListStyle())
            .scrollContentBackground(.hidden)
            .listSectionSpacing(20)
            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
            .listRowBackground(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.3))
            )
            .listSectionSeparator(.hidden)
            }
        }
    }
}

#Preview {
    SettingsView()
        .preferredColorScheme(.dark)
}
