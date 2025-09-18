// AccountCardView.swift
// Tarjeta de cuenta

import SwiftUI

struct AccountCardView: View {
    let account: Account
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Icono del tipo de cuenta
                Image(systemName: getAccountIcon())
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(getAccountColor())
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(account.name ?? "Sin nombre")
                        .font(.headline)
                    Text(account.type ?? "Cuenta")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Balance
                VStack(alignment: .trailing, spacing: 2) {
                    Text(account.balance.formatted(.currency(code: account.currency ?? "MXN")))
                        .font(.headline)
                        .contentTransition(.numericText())
                    
                    if let lastUpdated = account.lastUpdated {
                        Text("Actualizado \(formatRelativeDate(lastUpdated))")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            // Número de cuenta (parcialmente oculto)
            if let accountNumber = account.accountNumber {
                Text("•••• \(String(accountNumber.suffix(4)))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            getAccountColor().opacity(0.8),
                            getAccountColor().opacity(0.6)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .shadow(color: getAccountColor().opacity(0.3), radius: 8, y: 4)
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
    
    private func formatRelativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
