import SwiftUI
import CoreData

// MARK: - CORE DATA MANAGER: SUBSCRIPTIONS
extension CoreDataManager {
    
    // Fetch
    func fetchSubscriptions() -> [SubscriptionEntity] {
        let request: NSFetchRequest<SubscriptionEntity> = SubscriptionEntity.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \SubscriptionEntity.nextChargeDate, ascending: true)
        ]
        do {
            return try context.fetch(request)
        } catch {
            print("❌ Error al cargar suscripciones: \(error)")
            return []
        }
    }
    
    // Create
    @discardableResult
    func saveSubscription(
        name: String,
        amount: Double,
        frequency: SubscriptionFrequency,
        intervalDays: Int,
        nextChargeDate: Date,
        accountName: String,
        category: String,
        notes: String?,
        isActive: Bool
    ) -> SubscriptionEntity? {
        let sub = SubscriptionEntity(context: context)
        sub.id = UUID()
        sub.name = name
        sub.amount = amount
        sub.frequency = frequency.rawValue
        sub.intervalDays = Int16(intervalDays)
        sub.nextChargeDate = nextChargeDate
        sub.accountName = accountName
        sub.category = category
        sub.notes = notes
        sub.isActive = isActive
        sub.createdAt = Date()
        
        save()
        print("🧾 Suscripción guardada: \(name) - $\(amount) (\(frequency.rawValue)) en \(accountName)")
        return sub
    }
    
    // Update
    func updateSubscription(
        _ sub: SubscriptionEntity,
        name: String,
        amount: Double,
        frequency: SubscriptionFrequency,
        intervalDays: Int,
        nextChargeDate: Date,
        accountName: String,
        category: String,
        notes: String?,
        isActive: Bool
    ) {
        sub.name = name
        sub.amount = amount
        sub.frequency = frequency.rawValue
        sub.intervalDays = Int16(intervalDays)
        sub.nextChargeDate = nextChargeDate
        sub.accountName = accountName
        sub.category = category
        sub.notes = notes
        sub.isActive = isActive
        
        save()
        print("📝 Suscripción actualizada: \(name)")
    }
    
    // Delete
    func deleteSubscription(_ sub: SubscriptionEntity) {
        context.delete(sub)
        save()
        print("🗑️ Suscripción eliminada")
    }
    
    // MARK: - Registrar cobro ahora (crea transacción de gasto y avanza la fecha)
    func chargeSubscriptionNow(_ sub: SubscriptionEntity) {
        // Crear la transacción de gasto
        let _ = saveTransaction(
            name: sub.name ?? "Suscripción",
            amount: sub.amount,
            isIncome: false,
            accountName: sub.accountName ?? "",
            category: sub.category ?? "Servicios",
            date: Date(),
            notes: "Cobro de suscripción"
        )
        // Avanzar la próxima fecha
        let freq = SubscriptionFrequency(rawValue: sub.frequency ?? "") ?? .mensual
        let next = SubscriptionDateHelper.nextDate(after: sub.nextChargeDate ?? Date(), frequency: freq, intervalDays: Int(sub.intervalDays))
        sub.nextChargeDate = next
        save()
        print("✅ Cobro registrado y próxima fecha actualizada a \(sub.nextChargeDate ?? Date())")
    }
}

