import SwiftUI

struct LogsTab: View {
    @EnvironmentObject var logManager: LogManager
    @EnvironmentObject var settings: SettingsStore

    private var filteredLogs: [LogEntry] {
        if settings.logShowNull {
            return [LogEntry(message: "Отображение логов отключено", level: .info, timestamp: Date(), isEssential: true)]
        }
        return logManager.logs.filter { entry in
            entry.isEssential ||
            (settings.logShowInfo && entry.level == .info) ||
            (settings.logShowError && (entry.level == .error || entry.level == .warn))
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Журнал")
                    .font(.headline)
                Spacer()
                Button(action: { logManager.clearLogs() }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                Button(action: copyLogs) {
                    Image(systemName: "doc.on.doc")
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)

            HStack(spacing: 8) {
                FilterChip(
                    label: "INFO",
                    selected: settings.logShowInfo && !settings.logShowNull
                ) {
                    settings.logShowInfo.toggle()
                    settings.logShowNull = false
                }
                FilterChip(
                    label: "ERROR",
                    selected: settings.logShowError && !settings.logShowNull
                ) {
                    settings.logShowError.toggle()
                    settings.logShowNull = false
                }
                FilterChip(
                    label: "NULL",
                    selected: settings.logShowNull
                ) {
                    settings.logShowNull.toggle()
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 4) {
                        ForEach(filteredLogs) { entry in
                            LogLineView(entry: entry)
                                .id(entry.id)
                        }
                    }
                    .padding(.horizontal, 12)
                }
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(UIColor.systemBackground))
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 12)
                .onChange(of: filteredLogs.count) { _ in
                    if let last = filteredLogs.last {
                        withAnimation {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
    }

    private func copyLogs() {
        let text = filteredLogs.map { "\($0.message) (x\($0.count))" }.joined(separator: "\n")
        UIPasteboard.general.string = text
    }
}

private struct FilterChip: View {
    let label: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.caption)
                .fontWeight(selected ? .bold : .medium)
                .frame(maxWidth: .infinity)
                .frame(height: 36)
        }
        .buttonStyle(.borderedProminent)
        .tint(selected ? .blue : .gray.opacity(0.2))
        .foregroundColor(selected ? .white : .primary)
    }
}

private struct LogLineView: View {
    let entry: LogEntry

    private var color: Color {
        switch entry.level {
        case .error: return .red
        case .warn: return .orange
        case .info: return .green
        case .debug: return .blue
        }
    }

    private var iconName: String {
        switch entry.level {
        case .error: return "xmark.circle.fill"
        case .warn: return "exclamationmark.triangle.fill"
        case .info: return "info.circle.fill"
        case .debug: return "ladybug.fill"
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            Text("\(entry.count)")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.blue)
                .frame(minWidth: 20)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.blue.opacity(0.1))
                )

            Image(systemName: iconName)
                .font(.caption2)
                .foregroundColor(color.opacity(0.8))
                .frame(width: 14)

            Text(entry.message)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(color)
                .fontWeight(entry.level == .error ? .bold : .regular)
        }
    }
}
