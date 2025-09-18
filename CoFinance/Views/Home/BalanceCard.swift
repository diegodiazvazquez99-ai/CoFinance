// BalanceCard.swift
// Componente de tarjeta de balance

import SwiftUI

struct BalanceCard: View {
    let balance: Double
    let income: Double
    let expenses: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Balance Total")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text(balance.formatted(.currency(code: "MXN")))
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .contentTransition(.numericText()) // iOS 17+
            
            HStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Label("Ingresos", systemImage: "arrow.down.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.green)
                    Text(income.formatted(.currency(code: "MXN")))
                        .font(.headline)
                }
                
                VStack(alignment: .leading) {
                    Label("Gastos", systemImage: "arrow.up.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.red)
                    Text(expenses.formatted(.currency(code: "MXN")))
                        .font(.headline)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Material.liquidGlass)
                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
        )
    }
}
