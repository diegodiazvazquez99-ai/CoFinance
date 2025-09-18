// MARK: - AccountDetailView.swift
// Vista de detalle de cuenta

import SwiftUI
import Charts

struct AccountDetailView: View {
    let account: Account
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPeriod: TimePeriod = .month
    @State private var isEditing = false
    
    enum TimePeriod: String, CaseIterable {
        case week = "Semana"
        case month = "Mes"
        case year = "Año"
    }
    
    var transactions: [Transaction] {
        guard let transactions = account.transactions?.allObjects as? [Transaction] else {
            return []
        }
        return transactions.sorted(by: { ($0.date ?? Date()) > ($1.date ?? Date()) })
    }
    
    var filteredTransactions: [Transaction] {
        let calendar = Calendar.current
        let now = Date()
        
        return transactions.filter { transaction in
            guard let date = transaction.date else { return false }
            
            switch selectedPeriod {
            case .week:
                return calendar.dateComponents([.weekOfYear], from: date, to: now).weekOfYear ?? 0 == 0
            case .month:
                return calendar.dateComponents([.month], from: date, to: now).month ?? 0 == 0
            case .year:
                return calendar.dateComponents([.year], from: date, to: now).year ?? 0 == 0
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Tarjeta principal de la cuenta
                    AccountMainCard(account: account)
                        .padding(.horizontal)
                    
                    // Selector de período
                    Picker("Período", selection: $selectedPeriod) {
                        ForEach(TimePeriod.allCases, id: \.self) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // Gráfico de balance
                    if !filteredTransactions.isEmpty {
                        BalanceChart(transactions: filteredTransactions)
                            .frame(height: 200)
                            .padding(.horizontal)
                    }
                    
                    // Resumen del período
                    PeriodSummary(
                        transactions: filteredTransactions,
                        period: selectedPeriod
                    )
                    .padding(.horizontal)
                    
                    // Transacciones recientes
                    GroupBox("Transacciones recientes") {
                        if filteredTransactions.isEmpty {
                            Text("Sin transacciones en este período")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                        } else {
                            ForEach(filteredTransactions.prefix(10)) { transaction in
                                CompactTransactionRow(transaction: transaction)
                                if transaction != filteredTransactions.prefix(10).last {
                                    Divider()
                                }
                            }
                            
                            if filteredTransactions.count > 10 {
                                NavigationLink {
                                    TransactionsView()
                                } label: {
                                    Text("Ver todas (\(filteredTransactions.count))")
                                        .font(.caption)
                                        .foregroundStyle(.blue)
                                        .frame(maxWidth: .infinity)
                                        .padding(.top, 8)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Acciones
                    VStack(spacing: 12) {
                        Button {
                            // Transferir fondos
                        } label: {
                            Label("Transferir fondos", systemImage: "arrow.left.arrow.right")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.blue.opacity(0.1))
                                )
                                .foregroundStyle(.blue)
                        }
                        
                        Button(role: .destructive) {
                            deleteAccount()
                        } label: {
                            Label("Eliminar cuenta", systemImage: "trash.fill")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.red.opacity(0.1))
                                )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle(account.name ?? "Cuenta")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Editar") {
                        isEditing = true
                    }
                }
            }
        }
    }
    
    private func deleteAccount() {
        viewContext.delete(account)
        try? viewContext.save()
        dismiss()
    }
}

// MARK: - Helper Components

// DetailRow Component
struct DetailRow: View {
    let label: String
    let value: String
    var valueColor: Color = .primary
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline.bold())
                .foregroundStyle(valueColor)
        }
    }
}

// StatisticView Component
struct StatisticView: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            
            Text(value)
                .font(.headline)
                .contentTransition(.numericText())
            
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
}

// AccountMainCard Component
struct AccountMainCard: View {
    let account: Account
    
    var body: some View {
        VStack(spacing: 16) {
            // Diseño tipo tarjeta de crédito
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(account.bankName ?? "Banco")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                    
                    Text(account.name ?? "Mi Cuenta")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                }
                
                Spacer()
                
                Image(systemName: getAccountIcon())
                    .font(.largeTitle)
                    .foregroundStyle(.white.opacity(0.9))
            }
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 8) {
                if let accountNumber = account.accountNumber {
                    Text("•••• •••• •••• \(accountNumber)")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.9))
                        .tracking(2)
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Balance")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))
                        Text(account.balance.formatted(.currency(code: account.currency ?? "MXN")))
                            .font(.title.bold())
                            .foregroundStyle(.white)
                            .contentTransition(.numericText())
                    }
                    
                    Spacer()
                    
                    if account.type == "Crédito", let creditLimit = account.creditLimit, creditLimit > 0 {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Disponible")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.7))
                            Text((creditLimit - account.balance).formatted(.currency(code: account.currency ?? "MXN")))
                                .font(.headline)
                                .foregroundStyle(.white)
                        }
                    }
                }
            }
        }
        .padding(20)
        .frame(height: 200)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            getAccountColor(),
                            getAccountColor().opacity(0.8)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .shadow(color: getAccountColor().opacity(0.4), radius: 12, y: 6)
    }
    
    private func getAccountIcon() -> String {
        switch account.type {
        case "Débito": return "creditcard"
        case "Crédito": return "creditcard.fill"
        case "Ahorros": return "piggybank.fill"
        case "Inversión": return "chart.line.uptrend.xyaxis"
        default: return "dollarsign.circle.fill"
        }
    }
    
    private func getAccountColor() -> Color {
        switch account.type {
        case "Débito": return .blue
        case "Crédito": return .purple
        case "Ahorros": return .green
        case "Inversión": return .orange
        default: return .gray
        }
    }
}

// BalanceChart Component
struct BalanceChart: View {
    let transactions: [Transaction]
    
    var chartData: [(date: Date, balance: Double)] {
        var runningBalance = 0.0
        return transactions.reversed().map { transaction in
            runningBalance += transaction.amount
            return (date: transaction.date ?? Date(), balance: runningBalance)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Evolución del balance")
                .font(.headline)
            
            Chart(chartData, id: \.date) { item in
                LineMark(
                    x: .value("Fecha", item.date),
                    y: .value("Balance", item.balance)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .interpolationMethod(.catmullRom)
                
                AreaMark(
                    x: .value("Fecha", item.date),
                    y: .value("Balance", item.balance)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue.opacity(0.3), .purple.opacity(0.1)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)
            }
            .frame(height: 160)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Material.liquidGlass)
        )
    }
}

// PeriodSummary Component
struct PeriodSummary: View {
    let transactions: [Transaction]
    let period: AccountDetailView.TimePeriod
    
    var income: Double {
        transactions
            .filter { $0.type == TransactionType.income.rawValue }
            .reduce(0) { $0 + $1.amount }
    }
    
    var expenses: Double {
        transactions
            .filter { $0.type == TransactionType.expense.rawValue }
            .reduce(0) { $0 + abs($1.amount) }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            SummaryCard(
                title: "Ingresos",
                amount: income,
                icon: "arrow.down.circle.fill",
                color: .green
            )
            
            SummaryCard(
                title: "Gastos",
                amount: expenses,
                icon: "arrow.up.circle.fill",
                color: .red
            )
            
            SummaryCard(
                title: "Diferencia",
                amount: income - expenses,
                icon: "equal.circle.fill",
                color: income - expenses >= 0 ? .blue : .orange
            )
        }
    }
}

// SummaryCard Component
struct SummaryCard: View {
    let title: String
    let amount: Double
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text(abs(amount).formatted(.currency(code: "MXN")))
                .font(.subheadline.bold())
                .foregroundStyle(amount >= 0 ? .primary : .red)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Material.liquidGlass)
        )
    }
}

// CompactTransactionRow Component
struct CompactTransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack {
            Image(systemName: getIcon())
                .font(.caption)
                .foregroundStyle(getColor())
                .frame(width: 24, height: 24)
                .background(
                    Circle()
                        .fill(getColor().opacity(0.1))
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.title ?? "Sin título")
                    .font(.subheadline)
                    .lineLimit(1)
                
                Text(formatDate(transaction.date ?? Date()))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text(transaction.amount.formatted(.currency(code: "MXN")))
                .font(.subheadline.bold())
                .foregroundStyle(transaction.amount < 0 ? .red : .green)
        }
        .padding(.vertical, 4)
    }
    
    private func getIcon() -> String {
        guard let type = transaction.type else { return "circle" }
        return TransactionType(rawValue: type)?.icon ?? "circle"
    }
    
    private func getColor() -> Color {
        guard let type = transaction.type else { return .gray }
        return TransactionType(rawValue: type)?.color ?? .gray
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Extension for Tab View
extension View {
    func adaptiveTabBar() -> some View {
        self.modifier(AdaptiveTabBarModifier())
    }
}

struct AdaptiveTabBarModifier: ViewModifier {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    func body(content: Content) -> some View {
        if horizontalSizeClass == .regular {
            // iPad: permitir transformación a sidebar
            content
                .tabViewStyle(.sidebarAdaptable) // iOS 18+
        } else {
            // iPhone: tab bar flotante
            content
                .tabViewStyle(.floatingBar) // iOS 26 Liquid Glass
        }
    }
}
