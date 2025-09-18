// MiniTransactionRow.swift
// Fila compacta de transacción

import SwiftUI

struct MiniTransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack {
            Image(systemName: getIcon())
                .foregroundStyle(getColor())
                .font(.caption)
            
            Text(transaction.title ?? "")
                .font(.subheadline)
                .lineLimit(1)
            
            Spacer()
            
            Text(transaction.amount.formatted(.currency(code: "MXN")))
                .font(.subheadline.bold())
                .foregroundStyle(transaction.amount < 0 ? .red : .green)
        }
    }
    
    private func getIcon() -> String {
        guard let type = transaction.type else { return "circle.fill" }
        return TransactionType(rawValue: type)?.icon ?? "circle.fill"
    }
    
    private func getColor() -> Color {
        guard let type = transaction.type else { return .gray }
        return TransactionType(rawValue: type)?.color ?? .gray
    }
}
