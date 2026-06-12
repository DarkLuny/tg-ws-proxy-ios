import SwiftUI

struct ConnectionTab: View {
    @EnvironmentObject var proxyManager: ProxyManager
    @EnvironmentObject var settings: SettingsStore

    @State private var isStarting = false

    private var statusText: String {
        if isStarting { return "Подключение..." }
        if proxyManager.isRunning { return "Подключено" }
        return "Отключено"
    }

    private var statusColor: Color {
        if proxyManager.isRunning { return .green }
        if isStarting { return .orange }
        return .gray
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(proxyManager.isRunning ? Color.green.opacity(0.1) : Color.gray.opacity(0.05))
                        .frame(width: 180, height: 180)
                        .scaleEffect(proxyManager.isRunning ? 1.1 : 0.95)
                        .animation(.easeInOut(duration: 0.6), value: proxyManager.isRunning)

                    Image(systemName: "bolt.fill")
                        .font(.system(size: 60))
                        .foregroundColor(proxyManager.isRunning ? .green : .gray.opacity(0.5))
                        .scaleEffect(proxyManager.isRunning ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.4), value: proxyManager.isRunning)
                }
                .onTapGesture {
                    toggleProxy()
                }

                Text(statusText)
                    .font(.headline)
                    .foregroundColor(statusColor)

                Button(action: openTelegram) {
                    Text("Применить в Telegram")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                .disabled(!proxyManager.isRunning)

                VStack(spacing: 10) {
                    HStack {
                        StatusItem(
                            title: settings.cfproxyEnabled ? "CF" : "Direct",
                            subtitle: "Mode"
                        )
                        Divider().frame(height: 30)
                        StatusItem(
                            title: "\(settings.poolSize)",
                            subtitle: "Pool"
                        )
                        Divider().frame(height: 30)
                        StatusItem(
                            title: settings.port,
                            subtitle: "Port"
                        )
                        Divider().frame(height: 30)
                        StatusItem(
                            title: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0",
                            subtitle: "Ver"
                        )
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                }
                .padding(.horizontal)

                HStack {
                    Text(settings.proxyUrl())
                        .font(.caption)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .foregroundColor(.secondary)

                    Spacer()

                    Button(action: copyProxyUrl) {
                        Image(systemName: "doc.on.doc")
                            .foregroundColor(.blue)
                    }
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .padding(.horizontal)

                if proxyManager.isRunning {
                    Text(proxyManager.stats.description)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }

                Spacer()
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }

    private func toggleProxy() {
        if proxyManager.isRunning {
            proxyManager.stop()
            isStarting = false
        } else {
            isStarting = true
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
                DispatchQueue.main.async {
                    isStarting = false
                    _ = started
                }
            }
        }
    }

    private func openTelegram() {
        let url = settings.proxyUrl()
        if let urlObj = URL(string: url) {
            UIApplication.shared.open(urlObj)
        }
    }

    private func copyProxyUrl() {
        UIPasteboard.general.string = settings.proxyUrl()
    }
}

private struct StatusItem: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(minWidth: 50)
    }
}
