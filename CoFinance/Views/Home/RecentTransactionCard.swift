// RecentTransactionsCard.swift
// Tarjeta de transacciones recientes

import SwiftUI

struct RecentTransactionsCard: View {
    let transactions: [Transaction]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recientes")
                    .font(.headline)
                Spacer()
                NavigationLink(destination: TransactionsView()) {
                    Text("Ver todas")
                        .font(.caption)
                        .foregroundStyle(.blue)
                }
            }
            
            if transactions.isEmpty {
                Text("No hay transacciones recientes")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else {
                ForEach(transactions) { transaction in
                    MiniTransactionRow(transaction: transaction)
                    if transaction != transactions.last {
                        Divider()
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
}
