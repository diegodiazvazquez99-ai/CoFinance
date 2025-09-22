// TransactionRow.swift
// Fila de transacción

import SwiftUI

struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack {
            // Icono de categoría
            Image(systemName: getIcon())
                .font(.title2)
                .foregroundStyle(getColor())
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(getColor().opacity(0.1))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.title ?? "Sin título")
                    .font(.headline)
                Text(transaction.category ?? "Sin categoría")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(abs(transaction.amount).formatted(.currency(code: "MXN")))
                    .font(.headline)
                    .foregroundStyle(transaction.amount < 0 ? .red : .green)
                
                Text(formatTime(transaction.date ?? Date()))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func getIcon() -> String {
        guard let type = transaction.type else { return "questionmark.circle" }
        return TransactionType(rawValue: type)?.icon ?? "questionmark.circle"
    }
    
    private func getColor() -> Color {
        guard let type = transaction.type else { return .gray }
        return TransactionType(rawValue: type)?.color ?? .gray
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
