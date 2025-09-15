import SwiftUI
import Combine

// MARK: - ACCOUNT DETAIL VIEW
struct AccountDetailView: View {
    let account: Account
    @EnvironmentObject var coreDataManager: CoreDataManager
    @State private var transactions: [TransactionEntity] = []
    @State private var showingNewTransaction = false
    @State private var showingEditAccount = false
    @State private var accountEntity: AccountEntity?
    
    // Filtrar transacciones por esta cuenta
    var accountTransactions: [TransactionEntity] {
        transactions.filter { $0.accountName == account.name }
    }
    
    // Estadísticas de la cuenta
    var totalIncome: Double {
        accountTransactions.filter { $0.isIncome }.reduce(0) { $0 + $1.amount }
    }
    
    var totalExpenses: Double {
        accountTransactions.filter { !$0.isIncome }.reduce(0) { $0 + $1.amount }
    }
    
    var transactionCount: Int {
        accountTransactions.count
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // MARK: - Header Card de la Cuenta
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Circle()
                            .fill(account.colorValue)
                            .frame(width: 50, height: 50)
                            .overlay(
                                Image(systemName: account.typeIcon)
                                    .font(.title2)
                                    .foregroundColor(.white)
                            )
                            .shadow(color: account.colorValue.opacity(0.3), radius: 8, x: 0, y: 4)
                        
                        Spacer()
                        
                        Text(account.type)
                            .font(.caption2)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(account.colorValue.opacity(0.2), in: RoundedRectangle(cornerRadius: 8))
                            .foregroundColor(account.colorValue)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(account.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Balance actual")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("$\(account.balance, specifier: "%.2f")")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(account.balance >= 0 ? .primary : .red)
                            .contentTransition(.numericText())
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.ultraThinMaterial, lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                
                // MARK: - Estadísticas Rápidas
                HStack(spacing: 16) {
                    StatCard(
                        title: "Ingresos",
                        value: "$\(String(format: "%.2f", totalIncome))",
                        color: .green,
                        icon: "arrow.down.circle.fill"
                    )
                    
                    StatCard(
                        title: "Gastos",
                        value: "$\(String(format: "%.2f", totalExpenses))",
                        color: .red,
                        icon: "arrow.up.circle.fill"
                    )
                    
                    StatCard(
                        title: "Transacciones",
                        value: "\(transactionCount)",
                        color: .blue,
                        icon: "list.bullet.circle.fill"
                    )
                }
                
                // MARK: - Botones de Acción
                HStack(spacing: 12) {
                    // Botón Nueva Transacción
                    Button(action: {
                        showingNewTransaction = true
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                            Text("Nueva Transacción")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [account.colorValue, account.colorValue.opacity(0.7)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            in: RoundedRectangle(cornerRadius: 12)
                        )
                    }
                    .buttonStyle(.plain)
                    .shadow(color: account.colorValue.opacity(0.3), radius: 8, x: 0, y: 4)
                    
                    // Botón Editar Cuenta
                    Button(action: {
                        showingEditAccount = true
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "pencil.circle.fill")
                                .font(.title3)
                            Text("Editar")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.ultraThinMaterial, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
                
                // MARK: - Lista de Transacciones
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Transacciones de esta cuenta")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Spacer()
                        if !accountTransactions.isEmpty {
                            Text("\(accountTransactions.count)")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.secondary.opacity(0.2), in: RoundedRectangle(cornerRadius: 6))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    VStack(spacing: 12) {
                        if accountTransactions.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "tray")
                                    .font(.system(size: 40))
                                    .foregroundColor(.secondary)
                                
                                Text("No hay transacciones")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                Text("Las transacciones de esta cuenta aparecerán aquí")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                
                                Button("Crear primera transacción") {
                                    showingNewTransaction = true
                                }
                                .font(.headline)
                                .foregroundColor(account.colorValue)
                                .padding(.top, 8)
                            }
                            .frame(maxWidth: .infinity, minHeight: 150)
                            .padding(.vertical, 20)
                        } else {
                            ForEach(groupedAccountTransactions, id: \.key) { group in
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(group.key)
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                        .padding(.horizontal, 16)
                                    
                                    VStack(spacing: 8) {
                                        ForEach(group.value, id: \.id) { transaction in
                                            TransactionRowView(transaction: transaction.toTransaction())
                                                .padding(.horizontal, 16)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical, 16)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.ultraThinMaterial, lineWidth: 1)
                    )
                }
                
                Spacer(minLength: 100)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
        .navigationTitle(account.name)
        .navigationBarTitleDisplayMode(.large)
        .background(.ultraThinMaterial)
        .refreshable {
            loadTransactions()
        }
        .onAppear {
            loadTransactions()
            loadAccountEntity()
        }
        .sheet(isPresented: $showingNewTransaction) {
            NewTransactionView { transaction in
                loadTransactions()
            }
        }
        .sheet(isPresented: $showingEditAccount) {
            if let accountEntity = accountEntity {
                EditAccountView(
                    account: accountEntity.toAccount(),
                    onSave: { updatedAccount in
                        coreDataManager.updateAccount(
                            accountEntity,
                            name: updatedAccount.name,
                            type: updatedAccount.type,
                            balance: updatedAccount.balance,
                            color: updatedAccount.color
                        )
                        loadTransactions()
                    },
                    onDelete: { accountToDelete in
                        coreDataManager.deleteAccount(accountEntity)
                        // Aquí podrías agregar navegación hacia atrás si la cuenta se elimina
                    }
                )
            }
        }
    }
    
    // MARK: - Helper Properties
    private var groupedAccountTransactions: [(key: String, value: [TransactionEntity])] {
        let grouped = Dictionary(grouping: accountTransactions) { transaction in
            DateFormatter.monthYear.string(from: transaction.date ?? Date())
        }
        return grouped.sorted { first, second in
            DateFormatter.monthYear.date(from: first.key) ?? Date() >
            DateFormatter.monthYear.date(from: second.key) ?? Date()
        }
    }
    
    private func loadTransactions() {
        transactions = coreDataManager.fetchTransactions()
        print("💳 AccountDetailView para '\(account.name)' cargó:")
        print("   📊 \(accountTransactions.count) transacciones de esta cuenta")
        print("   💰 Balance: $\(account.balance)")
    }
    
    private func loadAccountEntity() {
        // Buscar la AccountEntity correspondiente para poder editarla
        let accounts = coreDataManager.fetchAccounts()
        accountEntity = accounts.first { $0.id == account.id }
    }
}

// MARK: - STAT CARD COMPONENT
struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.ultraThinMaterial, lineWidth: 1)
        )
    }
}
