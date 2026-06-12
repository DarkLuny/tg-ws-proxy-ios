import SwiftUI

struct InfoTab: View {
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var proxyManager: ProxyManager
    @EnvironmentObject var logManager: LogManager
    @State private var showHelp = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    heroCard

                    actionSection
                    projectSection

                    Spacer(minLength: 20)
                }
                .padding()
            }
            .navigationTitle("Информация")
            .sheet(isPresented: $showHelp) {
                HelpSheet()
            }
        }
    }

    private var heroCard: some View {
        VStack(spacing: 16) {
            HStack {
                Label("iOS Port", systemImage: "apple.logo")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.white.opacity(0.3))
                    .clipShape(Capsule())

                Label("Flowseal Base", systemImage: "arrow.triangle.branch")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.blue.opacity(0.2))
                    .clipShape(Capsule())
            }

            VStack(spacing: 8) {
                Text("Telegram WS Proxy")
                    .font(.title)
                    .fontWeight(.black)

                Text("MTProto-прокси для Telegram через CloudFlare WebSocket")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button(action: {}) {
                HStack {
                    Image(systemName: "heart.fill")
                    Text("Поддержать разработку")
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
            }
            .buttonStyle(.borderedProminent)
            .tint(.teal)
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
    }

    private var actionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: "Действия", icon: "bolt.fill", count: 3)

            ActionTile(
                title: "Справка",
                subtitle: "Как настроить и использовать прокси",
                icon: "questionmark.circle.fill",
                action: { showHelp = true }
            )

            ActionTile(
                title: "GitHub Issues",
                subtitle: "Сообщить об ошибке",
                icon: "ant.fill",
                action: { openUrl("https://github.com/amurcanov/tg-ws-proxy-android/issues/new") }
            )

            ActionTile(
                title: "Собрать отчёт",
                subtitle: "Копирует техническую информацию в буфер",
                icon: "doc.on.clipboard.fill",
                action: copyReport
            )
        }
    }

    private var projectSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: "О проекте", icon: "chevron.left.forwardslash.chevron.right", count: 3)

            LinkRow(
                title: "Оригинальный tg-ws-proxy",
                subtitle: "Flowseal",
                icon: "arrow.triangle.branch",
                url: "https://github.com/Flowseal/tg-ws-proxy"
            )

            LinkRow(
                title: "Android Fork",
                subtitle: "Amurcanov",
                icon: "smartphone",
                url: "https://github.com/amurcanov/tg-ws-proxy-android"
            )

            LinkRow(
                title: "MTProto Proxy Reference",
                subtitle: "Документация",
                icon: "doc.text",
                url: "https://core.telegram.org/mtproto/mtproto-transports"
            )
        }
    }

    private func copyReport() {
        var report = "App: TG WS Proxy iOS\n"
        report += "Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?")\n"
        report += "Settings: port=\(settings.port), pool=\(settings.poolSize), cf=\(settings.cfproxyEnabled)\n"
        report += "Stats: \(proxyManager.stats.description)\n"
        let errors = logManager.logs.filter { $0.level == .error }.suffix(5)
        if errors.isEmpty {
            report += "Errors: none\n"
        } else {
            report += "Errors:\n" + errors.map { "- \($0.message)" }.joined(separator: "\n") + "\n"
        }
        UIPasteboard.general.string = report
    }

    private func openUrl(_ urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}

private struct SectionHeader: View {
    let title: String
    let icon: String
    let count: Int

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            Text(title)
                .font(.headline)
                .foregroundColor(.blue)
            Spacer()
            Text("\(count)")
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color(.systemGray5))
                .clipShape(Capsule())
        }
        .padding(.top, 8)
    }
}

private struct ActionTile: View {
    let title: String
    let subtitle: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .frame(width: 36, height: 36)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(12)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

private struct LinkRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let url: String

    var body: some View {
        Button(action: {
            if let urlObj = URL(string: url) {
                UIApplication.shared.open(urlObj)
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .frame(width: 36, height: 36)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(12)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

struct HelpSheet: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    helpSection(
                        title: "CloudFlare CDN",
                        text: "Прокси перенаправляет трафик через CloudFlare WebSocket соединения для обхода блокировок. Включите эту опцию для автоматического выбора маршрута."
                    )
                    Divider()
                    helpSection(
                        title: "WS Pool",
                        text: "Пул WebSocket соединений. Больший размер = больше резервных соединений, но больше потребление памяти. Рекомендуется: 4."
                    )
                    Divider()
                    helpSection(
                        title: "Секретный ключ",
                        text: "Уникальный ключ для идентификации вашего прокси. Генерируется автоматически. Не меняйте его, если Telegram уже подключен."
                    )
                    Divider()
                    helpSection(
                        title: "Прямые DC адреса",
                        text: "Когда CloudFlare отключен, можно указать IP-адреса дата-центров Telegram напрямую. DC2 и DC4 используются по умолчанию."
                    )
                    Divider()
                    helpSection(
                        title: "Медленное подключение",
                        text: "Если подключение занимает много времени, попробуйте увеличить размер WS Pool или переключиться между CF и Direct режимом."
                    )
                }
                .padding()
            }
            .navigationTitle("Справка")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") { dismiss() }
                }
            }
        }
    }

    private func helpSection(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
                .foregroundColor(.blue)
            Text(text)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}
