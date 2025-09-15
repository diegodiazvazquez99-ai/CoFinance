import SwiftUI
import CoreData
import Foundation

// MARK: - TRANSACTION MODEL
struct Transaction: Identifiable, Codable {
    let id: UUID
    let name: String
    let amount: Double
    let isIncome: Bool
    let accountName: String
    let category: String
    let date: Date
    let notes: String?
    
    init(id: UUID = UUID(), name: String, amount: Double, isIncome: Bool, accountName: String, category: String, date: Date = Date(), notes: String? = nil) {
        self.id = id
        self.name = name
        self.amount = amount
        self.isIncome = isIncome
        self.accountName = accountName
        self.category = category
        self.date = date
        self.notes = notes
    }
    
    var formattedAmount: String {
        let sign = isIncome ? "+" : ""
        return "\(sign)$\(String(format: "%.2f", abs(amount)))"
    }
    
    var categoryIcon: String {
        switch category {
        case "Salario": return "briefcase.fill"
        case "Freelance": return "laptopcomputer"
        case "Inversiones": return "chart.line.uptrend.xyaxis"
        case "Otros ingresos": return "plus.circle.fill"
        case "Alimentación": return "fork.knife"
        case "Transporte": return "car.fill"
        case "Entretenimiento": return "gamecontroller.fill"
        case "Salud": return "cross.fill"
        case "Compras": return "bag.fill"
        case "Servicios": return "wifi"
        case "Otros gastos": return "minus.circle.fill"
        default: return isIncome ? "arrow.down.circle.fill" : "arrow.up.circle.fill"
        }
    }
}

// MARK: - TRANSACTION ENTITY EXTENSIONS
extension TransactionEntity {
    var formattedAmount: String {
        let sign = isIncome ? "+" : ""
        return "\(sign)$\(String(format: "%.2f", abs(amount)))"
    }
    
    var categoryIcon: String {
        switch category {
        case "Salario": return "briefcase.fill"
        case "Freelance": return "laptopcomputer"
        case "Inversiones": return "chart.line.uptrend.xyaxis"
        case "Otros ingresos": return "plus.circle.fill"
        case "Alimentación": return "fork.knife"
        case "Transporte": return "car.fill"
        case "Entretenimiento": return "gamecontroller.fill"
        case "Salud": return "cross.fill"
        case "Compras": return "bag.fill"
        case "Servicios": return "wifi"
        case "Otros gastos": return "minus.circle.fill"
        default: return isIncome ? "arrow.down.circle.fill" : "arrow.up.circle.fill"
        }
    }
    
    /// Convertir TransactionEntity a modelo Transaction para compatibilidad
    func toTransaction() -> Transaction {
        return Transaction(
            id: id ?? UUID(),
            name: name ?? "",
            amount: amount,
            isIncome: isIncome,
            accountName: accountName ?? "",
            category: category ?? "",
            date: date ?? Date(),
            notes: notes?.isEmpty == true ? nil : notes
        )
    }
}

// MARK: - TRANSACTION CATEGORIES
struct TransactionCategory {
    struct Income {
        static let salary = "Salario"
        static let freelance = "Freelance"
        static let investments = "Inversiones"
        static let other = "Otros ingresos"
        
        static let all = [salary, freelance, investments, other]
    }
    
    struct Expense {
        static let food = "Alimentación"
        static let transport = "Transporte"
        static let entertainment = "Entretenimiento"
        static let health = "Salud"
        static let shopping = "Compras"
        static let services = "Servicios"
        static let other = "Otros gastos"
        
        static let all = [food, transport, entertainment, health, shopping, services, other]
    }
    
    /// Obtiene el icono correspondiente a una categoría
    static func icon(for category: String, isIncome: Bool) -> String {
        switch category {
        case "Salario": return "briefcase.fill"
        case "Freelance": return "laptopcomputer"
        case "Inversiones": return "chart.line.uptrend.xyaxis"
        case "Otros ingresos": return "plus.circle.fill"
        case "Alimentación": return "fork.knife"
        case "Transporte": return "car.fill"
        case "Entretenimiento": return "gamecontroller.fill"
        case "Salud": return "cross.fill"
        case "Compras": return "bag.fill"
        case "Servicios": return "wifi"
        case "Otros gastos": return "minus.circle.fill"
        default: return isIncome ? "arrow.down.circle.fill" : "arrow.up.circle.fill"
        }
    }
    
    /// Obtiene todas las categorías según el tipo de transacción
    static func categories(for isIncome: Bool) -> [String] {
        return isIncome ? Income.all : Expense.all
    }
}
