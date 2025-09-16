import SwiftUI
import Foundation

// MARK: - ENVIRONMENT VALUES REACTIVO
extension EnvironmentValues {
    
    // 🚀 App Theme con @Entry (mantener como estaba)
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
    
    // REMOVIDO: currencyFormatter ya no es necesario como environment
    // Ahora usamos SettingsManager directamente
}

// MARK: - CURRENCY FORMATTING VIEW MODIFIER
struct CurrencyFormattingModifier: ViewModifier {
    @EnvironmentObject var settings: SettingsManager
    
    func body(content: Content) -> some View {
        content
            .environment(\.locale, Locale(identifier: localeIdentifier))
    }
    
    private var localeIdentifier: String {
        switch settings.preferredCurrency {
        case "USD": return "en_US"
        case "EUR": return "en_EU"
        case "GBP": return "en_GB"
        case "JPY": return "ja_JP"
        case "CAD": return "en_CA"
        case "AUD": return "en_AU"
        case "MXN": return "es_MX"
        case "BRL": return "pt_BR"
        case "CNY": return "zh_CN"
        case "INR": return "hi_IN"
        case "KRW": return "ko_KR"
        case "CHF": return "de_CH"
        case "SGD": return "en_SG"
        case "NOK": return "nb_NO"
        case "SEK": return "sv_SE"
        default: return "en_US"
        }
    }
}

extension View {
    func currencyFormatting() -> some View {
        modifier(CurrencyFormattingModifier())
    }
}
