import SwiftUI
import CoreData
import Foundation

// MARK: - ACCOUNT MODEL
struct Account: Identifiable, Codable {
    let id: UUID
    let name: String
    let type: String
    let balance: Double
    let color: String
    
    var colorValue: Color {
        switch color {
        case "blue": return .blue
        case "purple": return .purple
        case "green": return .green
        case "orange": return .orange
        case "red": return .red
        case "cyan": return .cyan
        default: return .blue
        }
    }
    
    var typeIcon: String {
        switch type {
        case "Banco": return "building.columns.fill"
        case "Crédito": return "creditcard.fill"
        case "Efectivo": return "banknote.fill"
        case "Ahorros": return "piggybank.fill"
        default: return "wallet.pass.fill"
        }
    }
}

// MARK: - ACCOUNT ENTITY EXTENSIONS
extension AccountEntity {
    var colorValue: Color {
        switch color {
        case "blue": return .blue
        case "purple": return .purple
        case "green": return .green
        case "orange": return .orange
        case "red": return .red
        case "cyan": return .cyan
        default: return .blue
        }
    }
    
    var typeIcon: String {
        switch type {
        case "Banco": return "building.columns.fill"
        case "Crédito": return "creditcard.fill"
        case "Efectivo": return "banknote.fill"
        case "Ahorros": return "piggybank.fill"
        default: return "wallet.pass.fill"
        }
    }
    
    /// Convertir AccountEntity a modelo Account para compatibilidad
    func toAccount() -> Account {
        return Account(
            id: id ?? UUID(),
            name: name ?? "",
            type: type ?? "",
            balance: balance,
            color: color ?? "blue"
        )
    }
}

// MARK: - ACCOUNT CONSTANTS
struct AccountType {
    static let bank = "Banco"
    static let credit = "Crédito"
    static let cash = "Efectivo"
    static let savings = "Ahorros"
    
    static let all = [bank, credit, cash, savings]
}

struct AccountColor {
    static let colorOptions = [
        ("blue", Color.blue),
        ("purple", Color.purple),
        ("green", Color.green),
        ("orange", Color.orange),
        ("red", Color.red),
        ("cyan", Color.cyan)
    ]
    
    /// Obtiene el Color de SwiftUI basado en el nombre del color
    static func color(from colorName: String) -> Color {
        switch colorName {
        case "blue": return .blue
        case "purple": return .purple
        case "green": return .green
        case "orange": return .orange
        case "red": return .red
        case "cyan": return .cyan
        default: return .blue
        }
    }
}
