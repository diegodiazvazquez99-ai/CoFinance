// PeriodSummary.swift
// Resumen del período

import SwiftUI

struct PeriodSummary: View {
let transactions: [Transaction]
let period: AccountDetailView.TimePeriod

```
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

var transfers: Double {
    transactions
        .filter { $0.type == TransactionType.transfer.rawValue }
        .reduce(0) { $0 + abs($1.amount) }
}

var netFlow: Double {
    income - expenses
}

var body: some View {
    VStack(spacing: 12) {
        HStack {
            Text("Resumen del \(period.rawValue.lowercased())")
                .font(.headline)
            Spacer()
            Text("\(transactions.count) transacciones")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        
        HStack(spacing: 12) {
            SummaryCard(
                title: "Ingresos",
                amount: income,
                icon: "arrow.down.circle.fill",
                color: .green,
                trend: calculateTrend(for: .income)
            )
            
            SummaryCard(
                title: "Gastos",
                amount: expenses,
                icon: "arrow.up.circle.fill",
                color: .red,
                trend: calculateTrend(for: .expense)
            )
            
            SummaryCard(
                title: "Diferencia",
                amount: netFlow,
                icon: "equal.circle.fill",
                color: netFlow >= 0 ? .blue : .orange,
                showTrend: false
            )
        }
        
        if transfers > 0 {
            HStack {
                Image(systemName: "arrow.left.arrow.right.circle.fill")
                    .foregroundStyle(.purple)
                Text("Transferencias:")
                Spacer()
                Text(transfers.formatted(.currency(code: "MXN")))
                    .font(.subheadline.bold())
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.purple.opacity(0.1))
            )
        }
        
        // Categorías más gastadas
        if !topCategories.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("Categorías principales")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                ForEach(topCategories, id: \.category) { item in
                    HStack {
                        Circle()
                            .fill(getCategoryColor(item.category))
                            .frame(width: 8, height: 8)
                        
                        Text(item.category)
                            .font(.caption)
                        
                        Spacer()
                        
                        Text(item.amount.formatted(.currency(code: "MXN")))
                            .font(.caption.bold())
                        
                        Text("(\(Int(item.percentage))%)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.top, 8)
        }
    }
}

private var topCategories: [(category: String, amount: Double, percentage: Double)] {
    let expenseTransactions = transactions.filter { $0.type == TransactionType.expense.rawValue }
    
    let grouped = Dictionary(grouping: expenseTransactions) { transaction in
        transaction.category ?? "Sin categoría"
    }
    
    let totals = grouped.mapValues { transactions in
        transactions.reduce(0) { $0 + abs($1.amount) }
    }
    
    let totalExpenses = expenses
    
    return totals
        .map { (category: $0.key, amount: $0.value, percentage: ($0.value / totalExpenses) * 100) }
        .sorted { $0.amount > $1.amount }
        .prefix(3)
        .map { $0 }
}

private func getCategoryColor(_ category: String) -> Color {
    switch category.lowercased() {
    case "comida", "alimentos": return .orange
    case "transporte": return .blue
    case "entretenimiento": return .purple
    case "servicios": return .green
    case "salud": return .red
    case "educación": return .indigo
    default: return .gray
    }
}

private func calculateTrend(for type: TransactionType) -> Double? {
    // Aquí podrías calcular la tendencia comparando con el período anterior
    // Por ahora retornamos nil para no mostrar tendencia
    return nil
}
```

}