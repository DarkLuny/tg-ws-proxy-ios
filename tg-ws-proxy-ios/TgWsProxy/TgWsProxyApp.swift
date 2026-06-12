import SwiftUI

@main
struct TgWsProxyApp: App {
    @StateObject private var proxyManager = ProxyManager.shared
    @StateObject private var settings = SettingsStore()
    @StateObject private var logManager = LogManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(proxyManager)
                .environmentObject(settings)
                .environmentObject(logManager)
                .preferredColorScheme(AppTheme(from: settings.themeMode).colorScheme)
        }
    }
}
