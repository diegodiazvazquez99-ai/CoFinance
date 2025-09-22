// TotalBalanceCard.swift
// Tarjeta de balance total

import SwiftUI

struct TotalBalanceCard: View {
    let totalBalance: Double
    let accountsCount: Int
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Balance total")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(totalBalance.formatted(.currency(code: "MXN")))
                        .font(.largeTitle.bold())
                        .contentTransition(.numericText())
                }
                Spacer()
            }
            
            Divider()
            
            HStack {
                Image(systemName: "creditcard.fill")
                    .foregroundStyle(.blue)
                Text("\(accountsCount) cuentas activas")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.blue.opacity(0.1),
                            Color.purple.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Material.liquidGlass, lineWidth: 1)
        )
    }
}
