// SubscriptionSummaryCard.swift
// Tarjeta de resumen de suscripciones

import SwiftUI

struct SubscriptionSummaryCard: View {
    let totalAmount: Double
    let activeCount: Int
    let upcomingPayments: Int
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total mensual")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(totalAmount.formatted(.currency(code: "MXN")))
                        .font(.title2.bold())
                        .contentTransition(.numericText())
                }
                
                Spacer()
                
                Image(systemName: "repeat.circle.fill")
                    .font(.title)
                    .foregroundStyle(.purple)
            }
            
            HStack(spacing: 20) {
                StatCard(
                    value: "\(activeCount)",
                    label: "Activas",
                    color: .green
                )
                
                StatCard(
                    value: "\(upcomingPayments)",
                    label: "Próximos pagos",
                    color: .orange
                )
                
                StatCard(
                    value: (totalAmount * 12).formatted(.currency(code: "MXN").prefix(6)) + "+",
                    label: "Anual",
                    color: .blue
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Material.liquidGlass)
        )
    }
}
