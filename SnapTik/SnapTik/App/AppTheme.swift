import SwiftUI

enum AppTheme {
    static let accent = Color(hex: "FE2C55")
    static let accentSecondary = Color(hex: "25F4EE")
    static let background = Color(hex: "0A0A0F")
    static let surface = Color(hex: "16161F")
    static let surfaceElevated = Color(hex: "1E1E2A")
    static let textPrimary = Color.white
    static let textSecondary = Color(hex: "A0A0B0")
    static let success = Color(hex: "34D399")
    static let error = Color(hex: "F87171")

    static let cornerRadius: CGFloat = 16
    static let padding: CGFloat = 20
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: Double
        switch hex.count {
        case 6:
            r = Double((int >> 16) & 0xFF) / 255
            g = Double((int >> 8) & 0xFF) / 255
            b = Double(int & 0xFF) / 255
        default:
            r = 1; g = 1; b = 1
        }
        self.init(red: r, green: g, blue: b)
    }
}

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
            )
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}
