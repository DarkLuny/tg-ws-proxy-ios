import Foundation

class SettingsStore: ObservableObject {
    private let defaults = UserDefaults.standard

    static let defaultPort = "1443"
    static let defaultPoolSize = 4
    static let defaultDc2Ip = "149.154.167.220"
    static let defaultDc4Ip = "149.154.167.220"

    private enum Keys {
        static let port = "port"
        static let poolSize = "pool_size"
        static let secretKey = "secret_key"
        static let cfproxyEnabled = "cfproxy_enabled"
        static let customCfDomainEnabled = "custom_cf_domain_enabled"
        static let customCfDomain = "custom_cf_domain"
        static let themeMode = "theme_mode"
        static let autoStartOnBoot = "auto_start_on_boot"
        static let isDcAuto = "is_dc_auto"
        static let dc1 = "dc1"
        static let dc2 = "dc2"
        static let dc3 = "dc3"
        static let dc4 = "dc4"
        static let dc5 = "dc5"
        static let dc203 = "dc203"
        static let dc1m = "dc1m"
        static let dc2m = "dc2m"
        static let dc3m = "dc3m"
        static let dc4m = "dc4m"
        static let dc5m = "dc5m"
        static let dc203m = "dc203m"
        static let isExperimentalMode = "is_experimental_mode"
        static let logShowInfo = "log_show_info"
        static let logShowError = "log_show_error"
        static let logShowNull = "log_show_null"
    }

    @Published var port: String {
        didSet { defaults.set(port, forKey: Keys.port) }
    }
    @Published var poolSize: Int {
        didSet { defaults.set(poolSize, forKey: Keys.poolSize) }
    }
    @Published var secretKey: String {
        didSet { defaults.set(secretKey, forKey: Keys.secretKey) }
    }
    @Published var cfproxyEnabled: Bool {
        didSet { defaults.set(cfproxyEnabled, forKey: Keys.cfproxyEnabled) }
    }
    @Published var customCfDomainEnabled: Bool {
        didSet { defaults.set(customCfDomainEnabled, forKey: Keys.customCfDomainEnabled) }
    }
    @Published var customCfDomain: String {
        didSet { defaults.set(customCfDomain, forKey: Keys.customCfDomain) }
    }
    @Published var themeMode: String {
        didSet { defaults.set(themeMode, forKey: Keys.themeMode) }
    }
    @Published var autoStartOnBoot: Bool {
        didSet { defaults.set(autoStartOnBoot, forKey: Keys.autoStartOnBoot) }
    }
    @Published var isDcAuto: Bool {
        didSet { defaults.set(isDcAuto, forKey: Keys.isDcAuto) }
    }
    @Published var isExperimentalMode: Bool {
        didSet { defaults.set(isExperimentalMode, forKey: Keys.isExperimentalMode) }
    }
    @Published var dc1: String { didSet { defaults.set(dc1, forKey: Keys.dc1) } }
    @Published var dc2: String { didSet { defaults.set(dc2, forKey: Keys.dc2) } }
    @Published var dc3: String { didSet { defaults.set(dc3, forKey: Keys.dc3) } }
    @Published var dc4: String { didSet { defaults.set(dc4, forKey: Keys.dc4) } }
    @Published var dc5: String { didSet { defaults.set(dc5, forKey: Keys.dc5) } }
    @Published var dc203: String { didSet { defaults.set(dc203, forKey: Keys.dc203) } }
    @Published var dc1m: String { didSet { defaults.set(dc1m, forKey: Keys.dc1m) } }
    @Published var dc2m: String { didSet { defaults.set(dc2m, forKey: Keys.dc2m) } }
    @Published var dc3m: String { didSet { defaults.set(dc3m, forKey: Keys.dc3m) } }
    @Published var dc4m: String { didSet { defaults.set(dc4m, forKey: Keys.dc4m) } }
    @Published var dc5m: String { didSet { defaults.set(dc5m, forKey: Keys.dc5m) } }
    @Published var dc203m: String { didSet { defaults.set(dc203m, forKey: Keys.dc203m) } }
    @Published var logShowInfo: Bool {
        didSet { defaults.set(logShowInfo, forKey: Keys.logShowInfo) }
    }
    @Published var logShowError: Bool {
        didSet { defaults.set(logShowError, forKey: Keys.logShowError) }
    }
    @Published var logShowNull: Bool {
        didSet { defaults.set(logShowNull, forKey: Keys.logShowNull) }
    }

    init() {
        port = defaults.string(forKey: Keys.port) ?? SettingsStore.defaultPort
        poolSize = defaults.object(forKey: Keys.poolSize) as? Int ?? SettingsStore.defaultPoolSize
        secretKey = defaults.string(forKey: Keys.secretKey) ?? ""
        cfproxyEnabled = defaults.object(forKey: Keys.cfproxyEnabled) as? Bool ?? true
        customCfDomainEnabled = defaults.object(forKey: Keys.customCfDomainEnabled) as? Bool ?? false
        customCfDomain = defaults.string(forKey: Keys.customCfDomain) ?? ""
        themeMode = defaults.string(forKey: Keys.themeMode) ?? "system"
        autoStartOnBoot = defaults.object(forKey: Keys.autoStartOnBoot) as? Bool ?? false
        isDcAuto = defaults.object(forKey: Keys.isDcAuto) as? Bool ?? true
        isExperimentalMode = defaults.object(forKey: Keys.isExperimentalMode) as? Bool ?? false
        dc1 = defaults.string(forKey: Keys.dc1) ?? ""
        dc2 = defaults.string(forKey: Keys.dc2) ?? SettingsStore.defaultDc2Ip
        dc3 = defaults.string(forKey: Keys.dc3) ?? ""
        dc4 = defaults.string(forKey: Keys.dc4) ?? SettingsStore.defaultDc4Ip
        dc5 = defaults.string(forKey: Keys.dc5) ?? ""
        dc203 = defaults.string(forKey: Keys.dc203) ?? ""
        dc1m = defaults.string(forKey: Keys.dc1m) ?? ""
        dc2m = defaults.string(forKey: Keys.dc2m) ?? ""
        dc3m = defaults.string(forKey: Keys.dc3m) ?? ""
        dc4m = defaults.string(forKey: Keys.dc4m) ?? ""
        dc5m = defaults.string(forKey: Keys.dc5m) ?? ""
        dc203m = defaults.string(forKey: Keys.dc203m) ?? ""
        logShowInfo = defaults.object(forKey: Keys.logShowInfo) as? Bool ?? true
        logShowError = defaults.object(forKey: Keys.logShowError) as? Bool ?? false
        logShowNull = defaults.object(forKey: Keys.logShowNull) as? Bool ?? false

        if secretKey.isEmpty {
            secretKey = SettingsStore.generateRandomSecret()
        }
    }

    func generateNewSecret() {
        secretKey = SettingsStore.generateRandomSecret()
    }

    static func generateRandomSecret() -> String {
        var bytes = [UInt8](repeating: 0, count: 16)
        _ = SecRandomCopyBytes(kSecRandomDefault, 16, &bytes)
        return bytes.map { String(format: "%02x", $0) }.joined()
    }

    func buildDcIps() -> String {
        if isDcAuto { return "" }

        var pairs: [String] = []
        if !dc1.isEmpty { pairs.append("1:\(dc1)") }
        if !dc2.isEmpty { pairs.append("2:\(dc2)") }
        if !dc3.isEmpty { pairs.append("3:\(dc3)") }
        if !dc4.isEmpty { pairs.append("4:\(dc4)") }

        if isExperimentalMode {
            if !dc5.isEmpty { pairs.append("5:\(dc5)") }
            if !dc203.isEmpty { pairs.append("203:\(dc203)") }
            if !dc1m.isEmpty { pairs.append("-1:\(dc1m)") }
            if !dc2m.isEmpty { pairs.append("-2:\(dc2m)") }
            if !dc3m.isEmpty { pairs.append("-3:\(dc3m)") }
            if !dc4m.isEmpty { pairs.append("-4:\(dc4m)") }
            if !dc5m.isEmpty { pairs.append("-5:\(dc5m)") }
            if !dc203m.isEmpty { pairs.append("-203:\(dc203m)") }
        }

        return pairs.joined(separator: ",")
    }

    func proxyUrl() -> String {
        let p = Int(port) ?? 1443
        let secret = secretKey.trimmingCharacters(in: .whitespacesAndNewlines)
        let safeSecret = secret.isEmpty ? "00000000000000000000000000000000" : secret
        return "https://t.me/proxy?server=127.0.0.1&port=\(p)&secret=dd\(safeSecret)"
    }
}
