import SwiftUI
import Foundation

// MARK: - ACCOUNT CONVENIENCE EXTENSIONS
extension Account {
    /// Convenience initializer que genera automáticamente un UUID
    /// Útil para previews, tests y creación rápida de cuentas
    init(name: String, type: String, balance: Double, color: String) {
        self.id = UUID()
        self.name = name
        self.type = type
        self.balance = balance
        self.color = color
    }
    
    /// Crea una cuenta de ejemplo para previews y testing
    static func example(
        name: String = "Cuenta de Ejemplo",
        type: String = AccountType.bank,
        balance: Double = 1000.0,
        color: String = "blue"
    ) -> Account {
        Account(
            name: name,
            type: type,
            balance: balance,
            color: color
        )
    }
    
    /// Cuentas de ejemplo predefinidas para previews
    static var examples: [Account] {
        [
            Account.example(
                name: "Cuenta Principal",
                type: AccountType.bank,
                balance: 5000.0,
                color: "blue"
            ),
            Account.example(
                name: "Tarjeta de Crédito",
                type: AccountType.credit,
                balance: -1250.0,
                color: "red"
            ),
            Account.example(
                name: "Efectivo",
                type: AccountType.cash,
                balance: 850.0,
                color: "green"
            ),
            Account.example(
                name: "Ahorros",
                type: AccountType.savings,
                balance: 15000.0,
                color: "orange"
            )
        ]
    }
}

// MARK: - ACCOUNT FORMATTING HELPERS
extension Account {
    /// Formatea el balance usando SettingsManager
    func formattedBalance(with settings: SettingsManager) -> String {
        return settings.formatCurrency(balance)
    }
    
    /// Formatea el balance con signo usando SettingsManager
    func formattedBalanceWithSign(with settings: SettingsManager) -> String {
        return settings.formatCurrencyWithSign(balance)
    }
    
    /// Estado de la cuenta basado en el balance
    var status: AccountStatus {
        if balance > 1000 {
            return .healthy
        } else if balance >= 0 {
            return .low
        } else {
            return .negative
        }
    }
    
    /// Color del estado para UI
    var statusColor: Color {
        switch status {
        case .healthy: return .green
        case .low: return .orange
        case .negative: return .red
        }
    }
}

// MARK: - ACCOUNT STATUS ENUM
enum AccountStatus {
    case healthy    // Balance > 1000
    case low        // Balance 0-1000
    case negative   // Balance < 0
    
    var description: String {
        switch self {
        case .healthy: return "Saludable"
        case .low: return "Bajo"
        case .negative: return "Negativo"
        }
    }
    
    var icon: String {
        switch self {
        case .healthy: return "checkmark.circle.fill"
        case .low: return "exclamationmark.triangle.fill"
        case .negative: return "xmark.circle.fill"
        }
    }
}
