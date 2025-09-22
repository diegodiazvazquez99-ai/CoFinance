// FundsDistributionChart.swift
// Gráfico de distribución de fondos

import SwiftUI
import Charts

struct FundsDistributionChart: View {
    let accounts: [Account]
    
    var chartData: [(type: String, amount: Double, color: Color)] {
        let grouped = Dictionary(grouping: accounts, by: { $0.type ?? "Otro" })
        return grouped.map { (key, accounts) in
            let total = accounts.reduce(0) { $0 + $1.balance }
            return (type: key, amount: total, color: getColorForType(key))
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Distribución de fondos")
                .font(.headline)
            
            Chart(chartData, id: \.type) { item in
                SectorMark(
                    angle: .value("Monto", item.amount),
                    innerRadius: .ratio(0.618),
                    angularInset: 1.5
                )
                .foregroundStyle(item.color)
                .cornerRadius(4)
            }
            .frame(height: 200)
            
            // Leyenda
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(chartData, id: \.type) { item in
                    HStack(spacing: 4) {
                        Circle()
                            .fill(item.color)
                            .frame(width: 8, height: 8)
                        Text(item.type)
                            .font(.caption)
                        Spacer()
                        Text(item.amount.formatted(.currency(code: "MXN")))
                            .font(.caption.bold())
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Material.liquidGlass)
        )
    }
    
    private func getColorForType(_ type: String) -> Color {
        switch type {
        case "Débito": return .blue
        case "Crédito": return .purple
        case "Ahorros": return .green
        case "Inversión": return .orange
        default: return .gray
        }
    }
}
