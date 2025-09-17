import SwiftUI
import CoreData
import Foundation

// MARK: - SUBSCRIPTION FREQUENCY
enum SubscriptionFrequency: String, Codable, CaseIterable, Identifiable {
    case mensual = "Mensual"
    case semanal = "Semanal"
    case anual = "Anual"
    case personalizado = "Personalizado"
    
    var id: String { rawValue }
    
    var displayName: String { rawValue }
}

// MARK: - SUBSCRIPTION MODEL
struct Subscription: Identifiable, Codable {
    let id: UUID
    var name: String
    var amount: Double
    var frequency: SubscriptionFrequency
    var intervalDays: Int
    var nextChargeDate: Date
    var accountName: String
    var category: String
    var notes: String?
    var isActive: Bool
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        name: String,
        amount: Double,
        frequency: SubscriptionFrequency,
        intervalDays: Int = 30,
        nextChargeDate: Date,
        accountName: String,
        category: String,
        notes: String? = nil,
        isActive: Bool = true,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.amount = amount
        self.frequency = frequency
        self.intervalDays = intervalDays
        self.nextChargeDate = nextChargeDate
        self.accountName = accountName
        self.category = category
        self.notes = notes
        self.isActive = isActive
        self.createdAt = createdAt
    }
}

// MARK: - SUBSCRIPTION ENTITY HELPERS
extension SubscriptionEntity {
    func toSubscription() -> Subscription {
        let freq = SubscriptionFrequency(rawValue: frequency ?? "") ?? .mensual
        return Subscription(
            id: id ?? UUID(),
            name: name ?? "",
            amount: amount,
            frequency: freq,
            intervalDays: Int(intervalDays),
            nextChargeDate: nextChargeDate ?? Date(),
            accountName: accountName ?? "",
            category: category ?? "",
            notes: notes?.isEmpty == true ? nil : notes,
            isActive: isActive,
            createdAt: createdAt ?? Date()
        )
    }
}

// MARK: - FREQUENCY DATE HELPER
enum SubscriptionDateHelper {
    static func nextDate(after date: Date, frequency: SubscriptionFrequency, intervalDays: Int) -> Date {
        let calendar = Calendar.current
        switch frequency {
        case .mensual:
            return calendar.date(byAdding: .month, value: 1, to: date) ?? date
        case .semanal:
            return calendar.date(byAdding: .day, value: 7, to: date) ?? date
        case .anual:
            return calendar.date(byAdding: .year, value: 1, to: date) ?? date
        case .personalizado:
            return calendar.date(byAdding: .day, value: max(1, intervalDays), to: date) ?? date
        }
    }
}

