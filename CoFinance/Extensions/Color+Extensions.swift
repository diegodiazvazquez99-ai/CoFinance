// Color+Extensions.swift
// Extensiones para Color

import SwiftUI

extension Color {
// MARK: - Colores personalizados de la app
static let primaryBackground = Color(“PrimaryBackground”)
static let secondaryBackground = Color(“SecondaryBackground”)
static let accentGreen = Color(red: 0.0, green: 0.8, blue: 0.4)
static let accentRed = Color(red: 0.9, green: 0.2, blue: 0.2)
static let accentBlue = Color(red: 0.0, green: 0.5, blue: 1.0)
static let accentPurple = Color(red: 0.6, green: 0.2, blue: 0.9)
static let accentOrange = Color(red: 1.0, green: 0.6, blue: 0.0)

```
// MARK: - Colores para categorías financieras
static let incomeGreen = Color(red: 0.2, green: 0.8, blue: 0.4)
static let expenseRed = Color(red: 0.9, green: 0.3, blue: 0.3)
static let transferBlue = Color(red: 0.3, green: 0.5, blue: 0.9)
static let savingsGold = Color(red: 1.0, green: 0.8, blue: 0.2)
static let investmentPurple = Color(red: 0.6, green: 0.4, blue: 0.9)

// MARK: - Conversión de Color

/// Convierte Color a hex string
var hexString: String {
    let uiColor = UIColor(self)
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    
    uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    
    return String(format: "#%02lX%02lX%02lX",
                  lround(Double(red * 255)),
                  lround(Double(green * 255)),
                  lround(Double(blue * 255)))
}

/// Inicializa Color desde hex string
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
        (a, r, g, b) = (255, 0, 0, 0)
    }
    
    self.init(
        .sRGB,
        red: Double(r) / 255,
        green: Double(g) / 255,
        blue:  Double(b) / 255,
        opacity: Double(a) / 255
    )
}

// MARK: - Utilidades

/// Retorna una versión más clara del color
func lighter(by amount: Double = 0.2) -> Color {
    return self.adjust(by: abs(amount))
}

/// Retorna una versión más oscura del color
func darker(by amount: Double = 0.2) -> Color {
    return self.adjust(by: -abs(amount))
}

/// Ajusta el brillo del color
private func adjust(by amount: Double) -> Color {
    let uiColor = UIColor(self)
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    
    uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    
    return Color(
        red: min(max(Double(red) + amount, 0), 1),
        green: min(max(Double(green) + amount, 0), 1),
        blue: min(max(Double(blue) + amount, 0), 1),
        opacity: Double(alpha)
    )
}

/// Retorna si el color es oscuro
var isDark: Bool {
    let uiColor = UIColor(self)
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    
    uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    
    let luminance = 0.299 * red + 0.587 * green + 0.114 * blue
    return luminance < 0.5
}

/// Color de contraste (blanco o negro)
var contrastColor: Color {
    return isDark ? .white : .black
}

/// Componentes RGB
var components: (red: Double, green: Double, blue: Double, opacity: Double) {
    let uiColor = UIColor(self)
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    
    uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    
    return (Double(red), Double(green), Double(blue), Double(alpha))
}
```

}