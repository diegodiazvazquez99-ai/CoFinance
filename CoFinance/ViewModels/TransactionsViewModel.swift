// TransactionViewModel.swift
// ViewModel para transacciones

import SwiftUI
import CoreData
import Combine

@MainActor
class TransactionViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let context = PersistenceController.shared.container.viewContext
    
    init() {
        observeChanges()
    }
    
    private func observeChanges() {
        NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.fetchTransactions()
            }
            .store(in: &cancellables)
    }
    
    func fetchTransactions() {
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)]
        
        do {
            transactions = try context.fetch(request)
        } catch {
            errorMessage = "Error al cargar transacciones: \(error.localizedDescription)"
        }
    }
    
    func addTransaction(title: String, amount: Double, type: TransactionType, category: String?) {
        let transaction = Transaction(context: context)
        transaction.id = UUID()
        transaction.title = title
        transaction.amount = type == .expense ? -abs(amount) : amount
        transaction.type = type.rawValue
        transaction.category = category
        transaction.date = Date()
        
        do {
            try context.save()
        } catch {
            errorMessage = "Error al guardar transacción: \(error.localizedDescription)"
        }
    }
}
