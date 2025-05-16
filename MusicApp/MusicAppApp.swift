//
//  MusicAppApp.swift
//  MusicApp
//
//  Created by RebuildCode on 2025/5/7.
//

import SwiftUI

@main
struct MusicAppApp: App {
    // 初始化音频管理器
    @StateObject private var audioManager = AudioManager.shared
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(audioManager)
                .onAppear {
                    // 应用启动时初始化文件监控
                    print("📱 应用程序启动")
                    MusicFileManager.shared.startMonitoring()
                }
        }
    }
}
