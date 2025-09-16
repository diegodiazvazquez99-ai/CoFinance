import SwiftUI
import Foundation

// MARK: - SUBSCRIPTION CONVENIENCE EXTENSIONS
extension Subscription {
    /// Convenience initializer que genera automáticamente un UUID y fechas
    /// Útil para previews, tests y creación rápida de suscripciones
    init(
        name: String,
        amount: Double,
        frequency: SubscriptionFrequency,
        accountName: String,
        category: String,
        intervalDays: Int = 30,
        notes: String? = nil,
        isActive: Bool = true
    ) {
        self.id = UUID()
        self.name = name
        self.amount = amount
        self.frequency = frequency
        self.intervalDays = intervalDays
        self.nextChargeDate = Date()
        self.accountName = accountName
        self.category = category
        self.notes = notes
        self.isActive = isActive
        self.createdAt = Date()
    }
    
    /// Crea una suscripción de ejemplo para previews y testing
    static func example(
        name: String = "Suscripción de Ejemplo",
        amount: Double = 15.99,
        frequency: SubscriptionFrequency = .mensual,
        accountName: String = "Tarjeta de Crédito",
        category: String = "Servicios",
        daysFromNow: Int = 0,
        intervalDays: Int = 30,
        notes: String? = nil,
        isActive: Bool = true
    ) -> Subscription {
        let calendar = Calendar.current
        let nextDate = calendar.date(byAdding: .day, value: daysFromNow, to: Date()) ?? Date()
        
        return Subscription(
            id: UUID(),
            name: name,
            amount: amount,
            frequency: frequency,
            intervalDays: intervalDays,
            nextChargeDate: nextDate,
            accountName: accountName,
            category: category,
            notes: notes,
            isActive: isActive,
            createdAt: Date()
        )
    }
    
    /// Suscripciones de ejemplo predefinidas para previews
    static var examples: [Subscription] {
        [
            Subscription.example(
                name: "Netflix",
                amount: 15.99,
                frequency: .mensual,
                accountName: "Tarjeta de Crédito",
                category: "Entretenimiento",
                daysFromNow: 5
            ),
            Subscription.example(
                name: "Spotify",
                amount: 9.99,
                frequency: .mensual,
                accountName: "Tarjeta de Crédito",
                category: "Entretenimiento",
                daysFromNow: 12
            ),
            Subscription.example(
                name: "iCloud Storage",
                amount: 2.99,
                frequency: .mensual,
                accountName: "Tarjeta de Crédito",
                category: "Servicios",
                daysFromNow: 20
            ),
            Subscription.example(
                name: "Office 365",
                amount: 99.99,
                frequency: .anual,
                accountName: "Cuenta Principal",
                category: "Servicios",
                daysFromNow: 90
            ),
            Subscription.example(
                name: "Gym Membership",
                amount: 49.99,
                frequency: .mensual,
                accountName: "Cuenta Principal",
                category: "Salud",
                daysFromNow: 3
            )
        ]
    }
}

// MARK: - SUBSCRIPTION FILTERING HELPERS
extension Subscription {
    /// Filtra si la suscripción coincide con una búsqueda de texto
    func matches(searchText: String) -> Bool {
        guard !searchText.isEmpty else { return true }
        
        let lowercaseSearch = searchText.lowercased()
        return name.lowercased().contains(lowercaseSearch) ||
               category.lowercased().contains(lowercaseSearch) ||
               accountName.lowercased().contains(lowercaseSearch) ||
               (notes?.lowercased().contains(lowercaseSearch) ?? false)
    }
    
    /// Verifica si la suscripción pertenece a una cuenta específica
    func belongsTo(account: String) -> Bool {
        return account == "Todas" || accountName == account
    }
    
    /// Verifica si la suscripción vence pronto (próximos 7 días)
    var isDueSoon: Bool {
        let calendar = Calendar.current
        let daysFromNow = calendar.dateComponents([.day], from: Date(), to: nextChargeDate).day ?? 0
        return daysFromNow <= 7 && daysFromNow >= 0
    }
    
    /// Verifica si la suscripción está vencida
    var isOverdue: Bool {
        nextChargeDate < Date()
    }
    
    /// Días hasta el próximo cobro (puede ser negativo si está vencida)
    var daysUntilNextCharge: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: nextChargeDate).day ?? 0
    }
}

// MARK: - SUBSCRIPTION CALCULATION HELPERS
extension Subscription {
    /// Calcula el costo mensual aproximado de la suscripción
    var monthlyApproximateCost: Double {
        switch frequency {
        case .mensual:
            return amount
        case .semanal:
            return amount * 4.0 // 4 semanas ≈ 1 mes
        case .anual:
            return amount / 12.0
        case .personalizado:
            let daysInMonth = 30.0
            let costPerDay = amount / Double(max(1, intervalDays))
            return costPerDay * daysInMonth
        }
    }
    
    /// Calcula el costo anual aproximado de la suscripción
    var yearlyApproximateCost: Double {
        monthlyApproximateCost * 12.0
    }
    
    /// Próxima fecha de cobro después de la actual
    var nextChargeAfterCurrent: Date {
        SubscriptionDateHelper.nextDate(after: nextChargeDate, frequency: frequency, intervalDays: intervalDays)
    }
}

// MARK: - SUBSCRIPTION ARRAY HELPERS
extension Array where Element == Subscription {
    /// Filtra suscripciones activas
    var activeSubscriptions: [Subscription] {
        filter { $0.isActive }
    }
    
    /// Filtra suscripciones inactivas
    var inactiveSubscriptions: [Subscription] {
        filter { !$0.isActive }
    }
    
    /// Suscripciones que vencen pronto
    var dueSoon: [Subscription] {
        filter { $0.isDueSoon }
    }
    
    /// Suscripciones vencidas
    var overdue: [Subscription] {
        filter { $0.isOverdue }
    }
    
    /// Costo mensual total aproximado
    var totalMonthlyCost: Double {
        reduce(0) { $0 + $1.monthlyApproximateCost }
    }
    
    /// Costo anual total aproximado
    var totalYearlyCost: Double {
        reduce(0) { $0 + $1.yearlyApproximateCost }
    }
    
    /// Agrupa suscripciones por mes de próximo cobro
    var groupedByNextChargeMonth: [(key: String, value: [Subscription])] {
        let grouped = Dictionary(grouping: self) { subscription in
            DateFormatter.monthYear.string(from: subscription.nextChargeDate)
        }
        return grouped.sorted { first, second in
            DateFormatter.monthYear.date(from: first.key) ?? Date() <
            DateFormatter.monthYear.date(from: second.key) ?? Date()
        }
    }
}
