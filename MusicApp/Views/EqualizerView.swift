import SwiftUI

struct EqualizerView: View {
    @EnvironmentObject private var audioManager: AudioManager
    @State private var isEqualizerEnabled = true
    @State private var presetSelection = 0
    @State private var sliderValues = Array(repeating: 0.5, count: 8)
    
    let frequencies = ["32Hz", "64Hz", "125Hz", "250Hz", "500Hz", "1kHz", "2kHz", "4kHz"]
    let presets = ["自定义", "流行", "摇滚", "爵士", "古典", "平衡"]
    
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
                        Toggle("均衡器", isOn: $isEqualizerEnabled)
                            .listRowBackground(Color.black.opacity(0.3))
                        
                        if isEqualizerEnabled {
                            Picker("预设", selection: $presetSelection) {
                                ForEach(0..<presets.count) { index in
                                    Text(presets[index]).tag(index)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .listRowBackground(Color.black.opacity(0.3))
                        }
                    }
                    
                    if isEqualizerEnabled {
                        Section(header: Text("频率调节").foregroundColor(.white)) {
                            VStack(spacing: 20) {
                                HStack(alignment: .bottom, spacing: 8) {
                                    ForEach(0..<8) { index in
                                        VStack {
                                            Slider(value: $sliderValues[index], in: 0...1, step: 0.1) {
                                                Text(frequencies[index])
                                            }
                                            .rotationEffect(.degrees(-90))
                                            .frame(width: 80, height: 20)
                                            
                                            Text(frequencies[index])
                                                .font(.caption2)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                                .frame(height: 120)
                                .padding(.vertical, 8)
                            }
                            .listRowBackground(Color.black.opacity(0.3))
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("均衡器")
            .navigationBarTitleDisplayMode(.inline)
            .foregroundColor(.white)
        }
    }
}

#Preview {
    NavigationView {
        EqualizerView()
            .environmentObject(AudioManager.shared)
            .preferredColorScheme(.dark)
    }
}