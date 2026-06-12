import SwiftUI

@main
struct TgWsProxyApp: App {
    @StateObject private var proxyManager = ProxyManager.shared
    @StateObject private var settings = SettingsStore()
    @StateObject private var logManager = LogManager.shared
    
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(proxyManager)
                .environmentObject(settings)
                .environmentObject(logManager)
                .preferredColorScheme(AppTheme(from: settings.themeMode).colorScheme)
                .onOpenURL { url in
                    handleURL(url)
                }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                checkAndRedirectToTelegram()
            }
        }
    }
    
    private func handleURL(_ url: URL) {
        guard url.scheme == "tgwsproxy" else { return }
        
        if !proxyManager.isRunning {
            startProxyAndRedirect()
        }
    }
    
    private func checkAndRedirectToTelegram() {
        if proxyManager.isRunning {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                if let url = URL(string: "tg://") {
                    UIApplication.shared.open(url)
                }
            }
        }
    }
    
    private func startProxyAndRedirect() {
        let dcIps = settings.buildDcIps()
        let port = Int(settings.port) ?? 1443
        let cfDomain = settings.customCfDomainEnabled ? settings.customCfDomain : ""
        
        DispatchQueue.global(qos: .userInitiated).async {
            let started = proxyManager.start(
                port: port,
                dcIps: dcIps,
                poolSize: settings.poolSize,
                cfEnabled: settings.cfproxyEnabled,
                cfPriority: true,
                cfDomain: cfDomain,
                secretKey: settings.secretKey
            )
            
            if started {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    if let url = URL(string: "tg://") {
                        UIApplication.shared.open(url)
                    }
                }
            }
        }
    }
}
