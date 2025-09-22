// AccountViewModel.swift
// ViewModel para cuentas

import SwiftUI
import CoreData
import Combine

@MainActor
class AccountViewModel: ObservableObject {
    @Published var accounts: [Account] = []
    @Published var totalBalance: Double = 0
    @Published var balanceByType: [String: Double] = [:]
    
    private var cancellables = Set<AnyCancellable>()
    private let context = PersistenceController.shared.container.viewContext
    
    init() {
        observeChanges()
    }
    
    private func observeChanges() {
        NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.fetchAccounts()
                self?.calculateBalances()
            }
            .store(in: &cancellables)
    }
    
    func fetchAccounts() {
        let request: NSFetchRequest<Account> = Account.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Account.balance, ascending: false)]
        
        do {
            accounts = try context.fetch(request)
        } catch {
            print("Error fetching accounts: \(error)")
        }
    }
    
    private func calculateBalances() {
        totalBalance = accounts.reduce(0) { $0 + $1.balance }
        
        balanceByType = Dictionary(grouping: accounts, by: { $0.type ?? "Otro" })
            .mapValues { accounts in
                accounts.reduce(0) { $0 + $1.balance }
            }
    }
    
    func updateAccountBalance(_ account: Account, newBalance: Double) {
        account.balance = newBalance
        account.lastUpdated = Date()
        
        do {
            try context.save()
        } catch {
            print("Error updating account balance: \(error)")
        }
    }
}
