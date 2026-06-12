import SwiftUI

enum AppTheme {
    case system, light, dark

    init(from mode: String) {
        switch mode {
        case "light": self = .light
        case "dark": self = .dark
        default: self = .system
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

enum AppColors {
    static let primary = Color("AccentColor", bundle: nil)

    static let terminalBg = Color(red: 0.08, green: 0.09, blue: 0.11)
    static let terminalBgDark = Color(red: 0.05, green: 0.06, blue: 0.08)
    static let terminalText = Color(red: 0.85, green: 0.85, blue: 0.87)
    static let terminalGreen = Color(red: 0.30, green: 0.85, blue: 0.40)
    static let terminalRed = Color(red: 0.95, green: 0.30, blue: 0.30)
    static let terminalOrange = Color(red: 1.0, green: 0.60, blue: 0.0)
    static let terminalBlue = Color(red: 0.40, green: 0.60, blue: 1.0)
    static let terminalCounter = Color(red: 0.30, green: 0.50, blue: 0.90)
}
