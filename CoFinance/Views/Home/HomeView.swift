// CoFinance/Views/Home/HomeView.swift
// HOMEVIEW SIN BOTÓN SCROLL TO TOP

import SwiftUI
import Combine
import CoreData

// MARK: - HOME VIEW SIMPLIFICADO Y CORREGIDO
struct HomeView: View {
    @Binding var selectedTab: CoFinanceTabs
    @EnvironmentObject var coreDataManager: CoreDataManager
    @State private var showingNewTransaction = false
    @State private var scrollPosition = ScrollPosition(edge: .top)
    
    // 🚀 Environment values (con fallbacks seguros)
    @Environment(\.currencyFormatter) private var currencyFormatter
    @Environment(\.appTheme) private var theme
    
    // 🔥 FetchRequest para actualizaciones automáticas
    @FetchRequest(
        entity: AccountEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \AccountEntity.createdAt, ascending: true)]
    ) var accounts: FetchedResults<AccountEntity>
    
    @FetchRequest(
        entity: TransactionEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \TransactionEntity.date, ascending: false)]
    ) var transactions: FetchedResults<TransactionEntity>
    
    var totalBalance: Double {
        accounts.reduce(0) { $0 + $1.balance }
    }
    
    var recentTransactions: [TransactionEntity] {
        Array(transactions.prefix(3))
    }
    
    var body: some View {
        NavigationView {
            // ScrollView simple sin botón scroll to top
            ScrollView {
                VStack(spacing: 24) {
                    // Balance Total Card
                    balanceCard
                    
                    // Botón Nueva Transacción
                    newTransactionButton
                    
                    // Transacciones Recientes
                    recentTransactionsSection
                    
                    // Resumen Rápido
                    if !accounts.isEmpty {
                        quickSummarySection
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .scrollPosition($scrollPosition, anchor: .top)
            .navigationTitle("CoFinance")
            .navigationBarTitleDisplayMode(.large)
            .background(Color("AppBackground"))
            .refreshable {
                await performRefresh()
            }
        }
        .sheet(isPresented: $showingNewTransaction) {
            NewTransactionView { transaction in
                print("✅ Nueva transacción creada: \(transaction.name)")
            }
        }
        .onAppear {
            logAppearance()
        }
    }
    
    // MARK: - BALANCE CARD CORREGIDO
    private var balanceCard: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Balance Total")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                    
                    Text("Actualizado ahora")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                
                Spacer()
                
                // Status indicator con colores seguros
                Circle()
                    .fill(totalBalance >= 0 ? Color.green : Color.red)
                    .frame(width: 8, height: 8)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 1)
                    )
            }
            
            // Balance amount
            VStack(spacing: 12) {
                Text(formatCurrency(totalBalance))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        totalBalance >= 0 ?
                        LinearGradient(
                            colors: [Color.primary, theme.accentColor],
                            startPoint: .leading,
                            endPoint: .trailing
                        ) :
                        LinearGradient(
                            colors: [Color.red, Color.orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .contentTransition(.numericText())
                
                // Trend indicator
                HStack(spacing: 8) {
                    Image(systemName: totalBalance >= 0 ? "arrow.up.right" : "arrow.down.right")
                        .foregroundColor(totalBalance >= 0 ? Color.green : Color.red)
                        .font(.caption)
                    
                    Text(totalBalance >= 0 ? "Situación saludable" : "Requiere atención")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .padding(.horizontal, 24)
        .background(
            RoundedRectangle(cornerRadius: theme.cornerRadius)
                .fill(.regularMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: theme.cornerRadius)
                        .stroke(.ultraThinMaterial, lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - NEW TRANSACTION BUTTON
    private var newTransactionButton: some View {
        Button(action: {
            showingNewTransaction = true
        }) {
            HStack(spacing: 12) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                Text("Nueva Transacción")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [theme.accentColor, theme.accentColor.opacity(0.7)]),
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                in: RoundedRectangle(cornerRadius: 16)
            )
        }
        .shadow(color: theme.accentColor.opacity(0.3), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - RECENT TRANSACTIONS SECTION
    private var recentTransactionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Transacciones Recientes")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
                Button("Ver todas") {
                    selectedTab = .transactions
                }
                .foregroundColor(theme.accentColor)
            }
            
            VStack(spacing: 12) {
                if recentTransactions.isEmpty {
                    emptyTransactionsView
                } else {
                    ForEach(recentTransactions, id: \.id) { transaction in
                        SimpleTransactionRowView(transaction: transaction.toTransaction())
                    }
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: theme.cornerRadius)
                    .fill(.thinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: theme.cornerRadius)
                            .stroke(.ultraThinMaterial, lineWidth: 1)
                    )
            )
        }
    }
    
    // MARK: - EMPTY TRANSACTIONS VIEW
    private var emptyTransactionsView: some View {
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
    }
    
    // MARK: - QUICK SUMMARY SECTION
    private var quickSummarySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Resumen")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
                Button("Ver cuentas") {
                    selectedTab = .accounts
                }
                .foregroundColor(theme.accentColor)
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
            .background(
                RoundedRectangle(cornerRadius: theme.cornerRadius)
                    .fill(.thinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: theme.cornerRadius)
                            .stroke(.ultraThinMaterial, lineWidth: 1)
                    )
            )
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
    private func formatCurrency(_ amount: Double) -> String {
        return currencyFormatter.string(from: NSNumber(value: amount)) ?? "$\(String(format: "%.2f", amount))"
    }
    
    private func performRefresh() async {
        print("🔄 Refresh manual en HomeView")
        try? await Task.sleep(nanoseconds: 500_000_000)
    }
    
    private func logAppearance() {
        print("🏠 HomeView apareció:")
        print("   💳 \(accounts.count) cuentas")
        print("   💸 \(transactions.count) transacciones")
        print("   💰 Balance total: \(formatCurrency(totalBalance))")
    }
}

// MARK: - SIMPLE TRANSACTION ROW VIEW (Sin conflictos)
struct SimpleTransactionRowView: View {
    let transaction: Transaction
    @Environment(\.currencyFormatter) private var currencyFormatter
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon simple
            Circle()
                .fill(transaction.isIncome ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: transaction.categoryIcon)
                        .foregroundColor(transaction.isIncome ? Color.green : Color.red)
                        .font(.title3)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.name)
                    .font(.headline)
                    .fontWeight(.medium)
                
                Text(transaction.category)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text((transaction.isIncome ? "+" : "") + formatTransactionAmount(transaction.amount))
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(transaction.isIncome ? Color.green : Color.red)
                
                Text(transaction.date.relativeString)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func formatTransactionAmount(_ amount: Double) -> String {
        return currencyFormatter.string(from: NSNumber(value: amount)) ?? "$\(String(format: "%.2f", amount))"
    }
}

// MARK: - PREVIEW
#Preview {
    HomeView(selectedTab: .constant(.home))
        .environmentObject(CoreDataManager.shared)
        .appTheme(AppTheme())
}
