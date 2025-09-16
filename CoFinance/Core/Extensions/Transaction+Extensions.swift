import SwiftUI
import Foundation

// MARK: - TRANSACTION CONVENIENCE EXTENSIONS
extension Transaction {
    /// Convenience initializer que genera automáticamente un UUID y usa Date actual
    /// Útil para previews, tests y creación rápida de transacciones
    init(
        name: String,
        amount: Double,
        isIncome: Bool,
        accountName: String,
        category: String,
        notes: String? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.amount = amount
        self.isIncome = isIncome
        self.accountName = accountName
        self.category = category
        self.date = Date()
        self.notes = notes
    }
    
    /// Crea una transacción de ejemplo para previews y testing
    static func example(
        name: String = "Transacción de Ejemplo",
        amount: Double = 100.0,
        isIncome: Bool = false,
        accountName: String = "Cuenta Principal",
        category: String = "Otros gastos",
        daysAgo: Int = 0,
        notes: String? = nil
    ) -> Transaction {
        let calendar = Calendar.current
        let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
        
        return Transaction(
            id: UUID(),
            name: name,
            amount: amount,
            isIncome: isIncome,
            accountName: accountName,
            category: category,
            date: date,
            notes: notes
        )
    }
    
    /// Transacciones de ejemplo predefinidas para previews
    static var examples: [Transaction] {
        [
            Transaction.example(
                name: "Salario",
                amount: 5000.0,
                isIncome: true,
                accountName: "Cuenta Principal",
                category: "Salario",
                daysAgo: 0
            ),
            Transaction.example(
                name: "Supermercado",
                amount: 120.50,
                isIncome: false,
                accountName: "Cuenta Principal",
                category: "Alimentación",
                daysAgo: 1
            ),
            Transaction.example(
                name: "Gasolina",
                amount: 45.00,
                isIncome: false,
                accountName: "Cuenta Principal",
                category: "Transporte",
                daysAgo: 2
            ),
            Transaction.example(
                name: "Freelance Web",
                amount: 800.0,
                isIncome: true,
                accountName: "Cuenta Principal",
                category: "Freelance",
                daysAgo: 7
            ),
            Transaction.example(
                name: "Netflix",
                amount: 15.99,
                isIncome: false,
                accountName: "Tarjeta de Crédito",
                category: "Entretenimiento",
                daysAgo: 10
            )
        ]
    }
}

// MARK: - TRANSACTION FILTERING HELPERS
extension Transaction {
    /// Filtra si la transacción coincide con una búsqueda de texto
    func matches(searchText: String) -> Bool {
        guard !searchText.isEmpty else { return true }
        
        let lowercaseSearch = searchText.lowercased()
        return name.lowercased().contains(lowercaseSearch) ||
               category.lowercased().contains(lowercaseSearch) ||
               accountName.lowercased().contains(lowercaseSearch) ||
               (notes?.lowercased().contains(lowercaseSearch) ?? false)
    }
    
    /// Verifica si la transacción pertenece a una cuenta específica
    func belongsTo(account: String) -> Bool {
        return account == "Todas" || accountName == account
    }
    
    /// Verifica si la transacción es del mes actual
    var isThisMonth: Bool {
        Calendar.current.isDate(date, equalTo: Date(), toGranularity: .month)
    }
    
    /// Verifica si la transacción es de esta semana
    var isThisWeek: Bool {
        Calendar.current.isDate(date, equalTo: Date(), toGranularity: .weekOfYear)
    }
}

// MARK: - TRANSACTION GROUPING HELPERS
extension Array where Element == Transaction {
    /// Agrupa transacciones por mes y año
    var groupedByMonth: [(key: String, value: [Transaction])] {
        let grouped = Dictionary(grouping: self) { transaction in
            DateFormatter.monthYear.string(from: transaction.date)
        }
        return grouped.sorted { first, second in
            DateFormatter.monthYear.date(from: first.key) ?? Date() >
            DateFormatter.monthYear.date(from: second.key) ?? Date()
        }
    }
    
    /// Agrupa transacciones por semana
    var groupedByWeek: [(key: String, value: [Transaction])] {
        let grouped = Dictionary(grouping: self) { transaction in
            let calendar = Calendar.current
            let weekOfYear = calendar.component(.weekOfYear, from: transaction.date)
            let year = calendar.component(.year, from: transaction.date)
            return "Semana \(weekOfYear), \(year)"
        }
        return grouped.sorted { first, second in
            // Simple string comparison should work for "Semana X, YYYY"
            first.key > second.key
        }
    }
    
    /// Calcula el total de ingresos
    var totalIncome: Double {
        filter { $0.isIncome }.reduce(0) { $0 + $1.amount }
    }
    
    /// Calcula el total de gastos
    var totalExpenses: Double {
        filter { !$0.isIncome }.reduce(0) { $0 + $1.amount }
    }
    
    /// Calcula el balance neto (ingresos - gastos)
    var netBalance: Double {
        totalIncome - totalExpenses
    }
}
