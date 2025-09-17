import SwiftUI
import Foundation
import Combine

// MARK: - SETTINGS MANAGER
@MainActor
final class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    
    // MARK: - Appearance Settings
    @Published var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
            print("🎨 Tema cambiado a: \(isDarkMode ? "Oscuro" : "Claro")")
        }
    }
    @Published var accentColorName: String {
        didSet { UserDefaults.standard.set(accentColorName, forKey: "accentColorName") }
    }
    
    // MARK: - Currency Settings
    @Published var preferredCurrency: String {
        didSet {
            UserDefaults.standard.set(preferredCurrency, forKey: "preferredCurrency")
            print("💱 Divisa cambiada a: \(preferredCurrency)")
        }
    }
    @Published var currencySymbol: String {
        didSet {
            UserDefaults.standard.set(currencySymbol, forKey: "currencySymbol")
            print("💰 Símbolo cambiado a: \(currencySymbol)")
        }
    }
    @Published var currencyName: String {
        didSet { UserDefaults.standard.set(currencyName, forKey: "currencyName") }
    }
    
    // MARK: - Notification Settings
    @Published var notificationsEnabled: Bool {
        didSet { UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled") }
    }
    @Published var reminderNotifications: Bool {
        didSet { UserDefaults.standard.set(reminderNotifications, forKey: "reminderNotifications") }
    }
    @Published var subscriptionNotifications: Bool {
        didSet { UserDefaults.standard.set(subscriptionNotifications, forKey: "subscriptionNotifications") }
    }
    @Published var transactionReminders: Bool {
        didSet { UserDefaults.standard.set(transactionReminders, forKey: "transactionReminders") }
    }
    
    // MARK: - Privacy & Security
    @Published var requireBiometrics: Bool {
        didSet { UserDefaults.standard.set(requireBiometrics, forKey: "requireBiometrics") }
    }
    @Published var hideBalancesInAppSwitcher: Bool {
        didSet { UserDefaults.standard.set(hideBalancesInAppSwitcher, forKey: "hideBalancesInAppSwitcher") }
    }
    
    // MARK: - Data & Storage
    @Published var autoBackup: Bool {
        didSet { UserDefaults.standard.set(autoBackup, forKey: "autoBackup") }
    }
    @Published var lastBackupDate: Date {
        didSet { UserDefaults.standard.set(lastBackupDate, forKey: "lastBackupDate") }
    }
    
    // MARK: - App Behavior
    @Published var defaultTransactionType: String {
        didSet { UserDefaults.standard.set(defaultTransactionType, forKey: "defaultTransactionType") }
    }
    @Published var showDecimalPlaces: Int {
        didSet { UserDefaults.standard.set(showDecimalPlaces, forKey: "showDecimalPlaces") }
    }
    @Published var groupTransactionsByMonth: Bool {
        didSet { UserDefaults.standard.set(groupTransactionsByMonth, forKey: "groupTransactionsByMonth") }
    }
    
    private init() {
        // Cargar valores desde UserDefaults
        self.isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        self.accentColorName = UserDefaults.standard.string(forKey: "accentColorName") ?? "blue"
        self.preferredCurrency = UserDefaults.standard.string(forKey: "preferredCurrency") ?? "USD"
        self.currencySymbol = UserDefaults.standard.string(forKey: "currencySymbol") ?? "$"
        self.currencyName = UserDefaults.standard.string(forKey: "currencyName") ?? "Dólar estadounidense"
        self.notificationsEnabled = UserDefaults.standard.object(forKey: "notificationsEnabled") as? Bool ?? true
        self.reminderNotifications = UserDefaults.standard.object(forKey: "reminderNotifications") as? Bool ?? true
        self.subscriptionNotifications = UserDefaults.standard.object(forKey: "subscriptionNotifications") as? Bool ?? true
        self.transactionReminders = UserDefaults.standard.bool(forKey: "transactionReminders")
        self.requireBiometrics = UserDefaults.standard.bool(forKey: "requireBiometrics")
        self.hideBalancesInAppSwitcher = UserDefaults.standard.object(forKey: "hideBalancesInAppSwitcher") as? Bool ?? true
        self.autoBackup = UserDefaults.standard.bool(forKey: "autoBackup")
        self.lastBackupDate = UserDefaults.standard.object(forKey: "lastBackupDate") as? Date ?? Date()
        self.defaultTransactionType = UserDefaults.standard.string(forKey: "defaultTransactionType") ?? "expense"
        self.showDecimalPlaces = UserDefaults.standard.object(forKey: "showDecimalPlaces") as? Int ?? 2
        self.groupTransactionsByMonth = UserDefaults.standard.object(forKey: "groupTransactionsByMonth") as? Bool ?? true
    }
    
    // MARK: - Computed Properties
    var accentColor: Color {
        switch accentColorName {
        case "blue": return .blue
        case "purple": return .purple
        case "green": return .green
        case "orange": return .orange
        case "red": return .red
        case "cyan": return .cyan
        case "indigo": return .indigo
        case "pink": return .pink
        default: return .blue
        }
    }
    
    var formattedCurrency: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = preferredCurrency
        formatter.currencySymbol = currencySymbol
        formatter.maximumFractionDigits = showDecimalPlaces
        formatter.minimumFractionDigits = showDecimalPlaces
        return formatter
    }
    
    // MARK: - Currency Formatting Methods
    func formatCurrency(_ amount: Double) -> String {
        return formattedCurrency.string(from: NSNumber(value: amount)) ?? "\(currencySymbol)\(String(format: "%.2f", amount))"
    }
    
    func formatCurrencyWithSign(_ amount: Double) -> String {
        let sign = amount >= 0 ? "+" : ""
        return sign + formatCurrency(abs(amount))
    }
    
    // MARK: - Methods
    func updateCurrency(code: String, symbol: String, name: String) {
        preferredCurrency = code
        currencySymbol = symbol
        currencyName = name
    }
    
    func resetToDefaults() {
        isDarkMode = false
        accentColorName = "blue"
        preferredCurrency = "USD"
        currencySymbol = "$"
        currencyName = "Dólar estadounidense"
        notificationsEnabled = true
        reminderNotifications = true
        subscriptionNotifications = true
        transactionReminders = false
        requireBiometrics = false
        hideBalancesInAppSwitcher = true
        autoBackup = false
        defaultTransactionType = "expense"
        showDecimalPlaces = 2
        groupTransactionsByMonth = true
        
        print("⚙️ Configuración restablecida a valores por defecto")
    }
    
    func exportSettings() -> [String: Any] {
        return [
            "isDarkMode": isDarkMode,
            "accentColorName": accentColorName,
            "preferredCurrency": preferredCurrency,
            "currencySymbol": currencySymbol,
            "currencyName": currencyName,
            "notificationsEnabled": notificationsEnabled,
            "reminderNotifications": reminderNotifications,
            "subscriptionNotifications": subscriptionNotifications,
            "transactionReminders": transactionReminders,
            "requireBiometrics": requireBiometrics,
            "hideBalancesInAppSwitcher": hideBalancesInAppSwitcher,
            "autoBackup": autoBackup,
            "defaultTransactionType": defaultTransactionType,
            "showDecimalPlaces": showDecimalPlaces,
            "groupTransactionsByMonth": groupTransactionsByMonth
        ]
    }
}

// MARK: - Currency Helper
struct CurrencyHelper {
    static let supportedCurrencies: [(code: String, name: String, symbol: String, flag: String)] = [
        ("USD", "Dólar estadounidense", "$", "🇺🇸"),
        ("EUR", "Euro", "€", "🇪🇺"),
        ("GBP", "Libra esterlina", "£", "🇬🇧"),
        ("JPY", "Yen japonés", "¥", "🇯🇵"),
        ("CAD", "Dólar canadiense", "C$", "🇨🇦"),
        ("AUD", "Dólar australiano", "A$", "🇦🇺"),
        ("CHF", "Franco suizo", "CHF", "🇨🇭"),
        ("CNY", "Yuan chino", "¥", "🇨🇳"),
        ("MXN", "Peso mexicano", "$", "🇲🇽"),
        ("BRL", "Real brasileño", "R$", "🇧🇷"),
        ("INR", "Rupia india", "₹", "🇮🇳"),
        ("KRW", "Won surcoreano", "₩", "🇰🇷"),
        ("SGD", "Dólar de Singapur", "S$", "🇸🇬"),
        ("NOK", "Corona noruega", "kr", "🇳🇴"),
        ("SEK", "Corona sueca", "kr", "🇸🇪")
    ]
    
    static func currencyInfo(for code: String) -> (name: String, symbol: String, flag: String)? {
        guard let currency = supportedCurrencies.first(where: { $0.code == code }) else {
            return nil
        }
        return (currency.name, currency.symbol, currency.flag)
    }
    
    static func formatAmount(_ amount: Double, with settings: SettingsManager) -> String {
        return settings.formatCurrency(amount)
    }
    
    static func formatAmountWithSign(_ amount: Double, with settings: SettingsManager) -> String {
        return settings.formatCurrencyWithSign(amount)
    }
}
