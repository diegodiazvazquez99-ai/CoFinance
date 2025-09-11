import SwiftUI
import Combine
import CoreData

// MARK: - CORE DATA MANAGER
class CoreDataManager: ObservableObject {
    static let shared = CoreDataManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoFinance")
        
        // Configuración para debugging
        container.persistentStoreDescriptions.forEach { storeDescription in
            storeDescription.shouldMigrateStoreAutomatically = true
            storeDescription.shouldInferMappingModelAutomatically = true
        }
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                print("❌ Core Data error: \(error), \(error.userInfo)")
                // En desarrollo, es útil recrear la base de datos si hay errores
                fatalError("Core Data error: \(error.localizedDescription)")
            } else {
                print("✅ Core Data store loaded successfully")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private init() {}
    
    func save() {
        let context = persistentContainer.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
                print("✅ Core Data guardado exitosamente")
            } catch {
                let nsError = error as NSError
                print("❌ Error al guardar Core Data: \(nsError), \(nsError.userInfo)")
                // En caso de error, podemos intentar hacer rollback
                context.rollback()
            }
        }
    }
    
    // MARK: - Account Operations
    func saveAccount(name: String, type: String, balance: Double, color: String) -> AccountEntity? {
        let account = AccountEntity(context: context)
        account.id = UUID()
        account.name = name
        account.type = type
        account.balance = balance
        account.color = color
        account.createdAt = Date()
        
        save()
        return account
    }
    
    func fetchAccounts() -> [AccountEntity] {
        let request: NSFetchRequest<AccountEntity> = AccountEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \AccountEntity.createdAt, ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("❌ Error al cargar cuentas: \(error)")
            return []
        }
    }
    
    func updateAccount(_ account: AccountEntity, name: String, type: String, balance: Double, color: String) {
        account.name = name
        account.type = type
        account.balance = balance
        account.color = color
        save()
    }
    
    func deleteAccount(_ account: AccountEntity) {
        context.delete(account)
        save()
    }
    
    // MARK: - Transaction Operations
    func saveTransaction(name: String, amount: Double, isIncome: Bool, accountName: String, category: String, date: Date, notes: String?) -> TransactionEntity? {
        let transaction = TransactionEntity(context: context)
        transaction.id = UUID()
        transaction.name = name
        transaction.amount = amount
        transaction.isIncome = isIncome
        transaction.accountName = accountName
        transaction.category = category
        transaction.date = date
        transaction.notes = notes
        
        save()
        return transaction
    }
    
    func fetchTransactions() -> [TransactionEntity] {
        let request: NSFetchRequest<TransactionEntity> = TransactionEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TransactionEntity.date, ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("❌ Error al cargar transacciones: \(error)")
            return []
        }
    }
    
    func updateTransaction(_ transaction: TransactionEntity, name: String, amount: Double, isIncome: Bool, accountName: String, category: String, date: Date, notes: String?) {
        transaction.name = name
        transaction.amount = amount
        transaction.isIncome = isIncome
        transaction.accountName = accountName
        transaction.category = category
        transaction.date = date
        transaction.notes = notes
        save()
    }
    
    func deleteTransaction(_ transaction: TransactionEntity) {
        context.delete(transaction)
        save()
    }
    
    // MARK: - Create Sample Data
    func createSampleDataIfNeeded() {
        let accounts = fetchAccounts()
        let transactions = fetchTransactions()
        
        // Solo crear datos de ejemplo si no hay ninguno
        if accounts.isEmpty && transactions.isEmpty {
            createSampleData()
        }
    }
    
    private func createSampleData() {
        // Crear cuentas de ejemplo
        let _ = saveAccount(name: "Cuenta Principal", type: "Banco", balance: 25430.50, color: "blue")
        let _ = saveAccount(name: "Tarjeta de Crédito", type: "Crédito", balance: -2150.00, color: "purple")
        let _ = saveAccount(name: "Efectivo", type: "Efectivo", balance: 850.00, color: "green")
        let _ = saveAccount(name: "Ahorros", type: "Banco", balance: 15000.00, color: "orange")
        
        // Crear transacciones de ejemplo
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today) ?? today
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today) ?? today
        let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: today) ?? today
        
        let _ = saveTransaction(name: "Salario", amount: 5000.00, isIncome: true, accountName: "Cuenta Principal", category: "Salario", date: today, notes: nil)
        let _ = saveTransaction(name: "Supermercado", amount: 120.50, isIncome: false, accountName: "Cuenta Principal", category: "Alimentación", date: yesterday, notes: nil)
        let _ = saveTransaction(name: "Gasolina", amount: 45.00, isIncome: false, accountName: "Cuenta Principal", category: "Transporte", date: twoDaysAgo, notes: nil)
        let _ = saveTransaction(name: "Freelance Web", amount: 800.00, isIncome: true, accountName: "Cuenta Principal", category: "Freelance", date: oneWeekAgo, notes: nil)
        let _ = saveTransaction(name: "Netflix", amount: 15.99, isIncome: false, accountName: "Tarjeta de Crédito", category: "Entretenimiento", date: oneWeekAgo, notes: nil)
        
        print("📝 Datos de ejemplo creados")
    }
}
