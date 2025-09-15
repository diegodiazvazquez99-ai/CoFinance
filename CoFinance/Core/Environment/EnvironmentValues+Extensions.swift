import SwiftUI
import Foundation

// MARK: - ENVIRONMENT VALUES SIMPLIFICADO (Sin errores)
extension EnvironmentValues {
    
    // 🚀 Currency Formatter con @Entry
    @Entry var currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter
    }()
    
    // 🚀 App Theme con @Entry
    @Entry var appTheme: AppTheme = AppTheme()
}

// MARK: - APP THEME MODEL SIMPLIFICADO
@Observable
final class AppTheme {
    var accentColor: Color = .blue
    var cornerRadius: CGFloat = 16
    var shadowOpacity: CGFloat = 0.1
    
    init(accentColor: Color = .blue, cornerRadius: CGFloat = 16, shadowOpacity: CGFloat = 0.1) {
        self.accentColor = accentColor
        self.cornerRadius = cornerRadius
        self.shadowOpacity = shadowOpacity
    }
}

// MARK: - VIEW EXTENSIONS
extension View {
    func appTheme(_ theme: AppTheme) -> some View {
        environment(\.appTheme, theme)
    }
    
    func currencyFormatter(_ formatter: NumberFormatter) -> some View {
        environment(\.currencyFormatter, formatter)
    }
}
