import SwiftUI

// MARK: - HOME VIEW
struct HomeView: View {
    @Binding var selectedTab: Int
    @EnvironmentObject var coreDataManager: CoreDataManager
    @State private var showingNewTransaction = false
    @State private var accounts: [AccountEntity] = []
    @State private var transactions: [TransactionEntity] = []
    
    var totalBalance: Double {
        accounts.reduce(0) { $0 + $1.balance }
    }
    
    var recentTransactions: [TransactionEntity] {
        Array(transactions.prefix(3))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - Balance Total Card
                    VStack(spacing: 16) {
                        Text("Balance Total")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Text("$\(totalBalance, specifier: "%.2f")")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .contentTransition(.numericText())
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
                    .padding(.horizontal, 24)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.ultraThinMaterial, lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    
                    // MARK: - Nueva Transacción Button
                    AnimatedButton(
                        title: "Nueva Transacción",
                        icon: "plus.circle.fill",
                        colors: [.blue, .cyan]
                    ) {
                        showingNewTransaction = true
                    }
                    
                    // MARK: - Transacciones Recientes
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Transacciones Recientes")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Spacer()
                            Button("Ver todas") {
                                selectedTab = 2
                            }
                            .foregroundColor(.blue)
                        }
                        
                        VStack(spacing: 12) {
                            if recentTransactions.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "list.bullet.clipboard")
                                        .font(.system(size: 32))
                                        .foregroundColor(.secondary)
                                    
                                    Text("No hay transacciones")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                    
                                    Text("Agrega tu primera transacción usando el botón de arriba")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity, minHeight: 100)
                                .padding(.vertical, 20)
                            } else {
                                ForEach(recentTransactions, id: \.id) { transaction in
                                    TransactionRowView(transaction: transaction.toTransaction())
                                }
                            }
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 20)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.ultraThinMaterial, lineWidth: 1)
                        )
                    }
                    
                    // MARK: - Resumen Rápido (si hay cuentas)
                    if !accounts.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Resumen")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                Spacer()
                                Button("Ver cuentas") {
                                    selectedTab = 1
                                }
                                .foregroundColor(.blue)
                            }
                            
                            VStack(spacing: 12) {
                                HStack {
                                    Text("Total de cuentas:")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("\(accounts.count)")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                }
                                
                                Divider()
                                
                                HStack {
                                    Text("Transacciones este mes:")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("\(transactionsThisMonth)")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                }
                            }
                            .padding(.vertical, 16)
                            .padding(.horizontal, 20)
                            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(.ultraThinMaterial, lineWidth: 1)
                            )
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .navigationTitle("CoFinance")
            .navigationBarTitleDisplayMode(.large)
            .background(.ultraThinMaterial)
            .refreshable {
                loadData()
            }
        }
        .onAppear {
            loadData()
        }
        .sheet(isPresented: $showingNewTransaction) {
            NewTransactionView { transaction in
                loadData()
            }
        }
    }
    
    // MARK: - Helper Computed Properties
    private var transactionsThisMonth: Int {
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date())
        let currentYear = calendar.component(.year, from: Date())
        
        return transactions.filter { transaction in
            guard let date = transaction.date else { return false }
            let transactionMonth = calendar.component(.month, from: date)
            let transactionYear = calendar.component(.year, from: date)
            return transactionMonth == currentMonth && transactionYear == currentYear
        }.count
    }
    
    // MARK: - Helper Methods
    private func loadData() {
        accounts = coreDataManager.fetchAccounts()
        transactions = coreDataManager.fetchTransactions()
        
        print("🏠 HomeView cargó:")
        print("   💳 \(accounts.count) cuentas")
        print("   💸 \(transactions.count) transacciones")
        print("   💰 Balance total: $\(totalBalance)")
    }
}
