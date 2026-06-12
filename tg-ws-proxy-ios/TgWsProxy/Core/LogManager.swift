import Foundation

enum LogLevel: String {
    case info = "INFO"
    case warn = "WARN"
    case error = "ERROR"
    case debug = "DEBUG"
}

struct LogEntry: Identifiable {
    let id = UUID()
    let message: String
    let level: LogLevel
    let timestamp: Date
    var count: Int = 1
    var isEssential: Bool = false
}

class LogManager: ObservableObject {
    static let shared = LogManager()

    @Published var logs: [LogEntry] = []

    private let essentialMarkers = [
        "pool", "key:", "started", "address:", "error", "failed", "blocked",
        "Пул", "Ключ:", "запущен", "Адрес:", "ошибка", "провалены", "заблокирован"
    ]

    private init() {}

    func addLog(_ message: String, level: LogLevel = .info) {
        let cleaned = message
            .replacingOccurrences(of: "[↑↓].*", with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let isEssential = essentialMarkers.contains { cleaned.localizedCaseInsensitiveContains($0) }

        let entry = LogEntry(
            message: cleaned,
            level: level,
            timestamp: Date(),
            isEssential: isEssential
        )

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let last = self.logs.last, last.message == entry.message {
                self.logs[self.logs.count - 1].count += 1
            } else {
                self.logs.append(entry)
                if self.logs.count > 100 {
                    self.logs.removeFirst()
                }
            }
        }
    }

    func clearLogs() {
        DispatchQueue.main.async {
            self.logs = []
        }
    }
}
