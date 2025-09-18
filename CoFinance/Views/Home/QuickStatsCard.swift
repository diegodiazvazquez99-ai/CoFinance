// QuickStatsCard.swift
// Tarjeta de estadísticas rápidas

import SwiftUI

struct QuickStatsCard: View {
    let title: String
    let amount: Double
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Spacer()
            }
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text(formatAmount(amount))
                .font(.headline)
                .contentTransition(.numericText())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Material.liquidGlass)
        )
    }
    
    private func formatAmount(_ value: Double) -> String {
        if title == "Metas" {
            return "\(Int(value * 100))%"
        } else {
            return value.formatted(.currency(code: "MXN"))
        }
    }
}
