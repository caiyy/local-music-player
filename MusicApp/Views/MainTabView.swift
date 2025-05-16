import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            PlaylistView()
                .tabItem {
                    Image(systemName: "music.note.list")
                    Text("播放列表")
                }
                .tag(1)
            
            PlayView()
                .tabItem {
                    Image(systemName: "play.circle.fill")
                    Text("播放")
                }
                .tag(0)
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("设置")
                }
                .tag(2)
        }
        .accentColor(.white)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    MainTabView()
}