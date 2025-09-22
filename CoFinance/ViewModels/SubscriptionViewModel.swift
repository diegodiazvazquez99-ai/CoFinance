// SubscriptionViewModel.swift
// ViewModel para suscripciones

import SwiftUI
import CoreData
import Combine

@MainActor
class SubscriptionViewModel: ObservableObject {
    @Published var subscriptions: [Subscription] = []
    @Published var monthlyTotal: Double = 0
    @Published var yearlyTotal: Double = 0
    
    private var cancellables = Set<AnyCancellable>()
    private let context = PersistenceController.shared.container.viewContext
    
    init() {
        observeChanges()
    }
    
    private func observeChanges() {
        NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.fetchSubscriptions()
                self?.calculateTotals()
            }
            .store(in: &cancellables)
    }
    
    func fetchSubscriptions() {
        let request: NSFetchRequest<Subscription> = Subscription.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Subscription.nextPaymentDate, ascending: true)]
        request.predicate = NSPredicate(format: "isActive == %@", NSNumber(value: true))
        
        do {
            subscriptions = try context.fetch(request)
        } catch {
            print("Error fetching subscriptions: \(error)")
        }
    }
    
    private func calculateTotals() {
        monthlyTotal = subscriptions.reduce(0) { total, subscription in
            let monthlyAmount = calculateMonthlyAmount(
                amount: subscription.amount,
                cycle: subscription.billingCycle ?? "Mensual"
            )
            return total + monthlyAmount
        }
        
        yearlyTotal = monthlyTotal * 12
    }
    
    private func calculateMonthlyAmount(amount: Double, cycle: String) -> Double {
        switch cycle {
        case "Semanal":
            return amount * 4.33
        case "Anual":
            return amount / 12
        default:
            return amount
        }
    }
}
