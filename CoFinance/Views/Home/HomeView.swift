// HomeView.swift
// Vista de Inicio con resumen financiero

import SwiftUI
import Charts

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showSettings = false
    @State private var balance: Double = 0
    @State private var monthlyIncome: Double = 0
    @State private var monthlyExpenses: Double = 0
    
    // Datos en tiempo real con Core Data
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)],
        animation: .smooth
    ) private var recentTransactions: FetchedResults<Transaction>
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Balance Card con Liquid Glass
                    BalanceCard(
                        balance: balance,
                        income: monthlyIncome,
                        expenses: monthlyExpenses
                    )
                    .padding(.horizontal)
                    
                    // Gráfico de gastos con MeshGradient (iOS 18+)
                    SpendingChart()
                        .frame(height: 200)
                        .padding(.horizontal)
                    
                    // Transacciones recientes
                    RecentTransactionsCard(transactions: Array(recentTransactions.prefix(5)))
                        .padding(.horizontal)
                    
                    // Tarjetas de resumen
                    HStack(spacing: 12) {
                        QuickStatsCard(
                            title: "Ahorros",
                            amount: calculateSavings(),
                            icon: "piggybank.fill",
                            color: .green
                        )
                        
                        QuickStatsCard(
                            title: "Metas",
                            amount: calculateGoalProgress(),
                            icon: "target",
                            color: .blue
                        )
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .refreshable { // Pull to refresh iOS 15+
                await updateData()
            }
            .navigationTitle("CoFinance")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Inicio")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.primary)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings.toggle()
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .symbolEffect(.pulse, isActive: showSettings) // iOS 17+
                            .foregroundStyle(.tint)
                    }
                }
            }
            .liquidGlassToolbar()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .presentationDetents([.medium, .large]) // iOS 16+
                .presentationDragIndicator(.visible)
                .presentationBackground(Material.liquidGlass) // iOS 26
        }
        .onAppear {
            updateBalance()
        }
    }
    
    private func updateBalance() {
        // Calcular balance en tiempo real
        balance = recentTransactions.reduce(0) { $0 + $1.amount }
        monthlyIncome = recentTransactions
            .filter { $0.type == TransactionType.income.rawValue }
            .reduce(0) { $0 + $1.amount }
        monthlyExpenses = recentTransactions
            .filter { $0.type == TransactionType.expense.rawValue }
            .reduce(0) { $0 + abs($1.amount) }
    }
    
    private func calculateSavings() -> Double {
        return monthlyIncome - monthlyExpenses
    }
    
    private func calculateGoalProgress() -> Double {
        return 0.75 // 75% de progreso ejemplo
    }
    
    @MainActor
    private func updateData() async {
        // Simular actualización de datos
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        updateBalance()
    }
}
