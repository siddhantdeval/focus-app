import SwiftUI

// Tailwind Colors
extension Color {
    static let primaryBackground = Color(hex: "#111827")
    static let backgroundLight = Color(hex: "#ffffff")
    static let backgroundDark = Color(hex: "#0a0a0a")
    
    // Slate scale
    static let slate50 = Color(hex: "#F8FAFC")
    static let slate100 = Color(hex: "#F1F5F9")
    static let slate200 = Color(hex: "#E2E8F0")
    static let slate300 = Color(hex: "#CBD5E1")
    static let slate400 = Color(hex: "#94A3B8")
    static let slate500 = Color(hex: "#64748B")
    static let slate700 = Color(hex: "#334155")
    static let slate800 = Color(hex: "#1E293B")
    static let slate900 = Color(hex: "#0F172A")
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Typography Scale (Inter equivalent in San Francisco)
struct TWFont {
    static let xs = Font.system(size: 12)
    static let sm = Font.system(size: 14)
    static let base = Font.system(size: 16)
    static let lg = Font.system(size: 18)
    static let xl = Font.system(size: 20)
    static let xxl = Font.system(size: 24)
    static let xxxl = Font.system(size: 36) // e.g. Pomodoro display
}

// Spacing Scale (1 = 4px)
struct TWSpacing {
    static func p(_ n: CGFloat) -> CGFloat { n * 4 }
}

// Custom ViewModifier DSL
struct TailwindModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
    }
}
