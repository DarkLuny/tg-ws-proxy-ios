import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            ConnectionTab()
                .tabItem {
                    Label("Proxy", systemImage: "power")
                }
                .tag(0)

            SettingsTab()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(1)

            LogsTab()
                .tabItem {
                    Label("Logs", systemImage: "terminal")
                }
                .tag(2)

            InfoTab()
                .tabItem {
                    Label("Info", systemImage: "info.circle")
                }
                .tag(3)
        }
        .tint(.blue)
    }
}
