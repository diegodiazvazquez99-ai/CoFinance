import SwiftUI

// MARK: - TRANSACTION ROW VIEW (Para Home y vistas principales)
struct TransactionRowView: View {
    let transaction: Transaction
    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(transaction.isIncome ? .green.opacity(0.2) : .red.opacity(0.2))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: transaction.categoryIcon)
                        .foregroundColor(transaction.isIncome ? .green : .red)
                        .font(.title3)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.name)
                    .font(.headline)
                    .fontWeight(.medium)
                
                Text(transaction.category)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(transaction.formattedAmount)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(transaction.isIncome ? .green : .red)
                
                Text(transaction.date.relativeString)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - TRANSACTION ROW DETAILED VIEW (Para lista de transacciones)
struct TransactionRowDetailedView: View {
    let transaction: Transaction
    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(transaction.isIncome ? .green.opacity(0.2) : .red.opacity(0.2))
                .frame(width: 48, height: 48)
                .overlay(
                    Image(systemName: transaction.categoryIcon)
                        .foregroundColor(transaction.isIncome ? .green : .red)
                        .font(.title3)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(transaction.name)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(transaction.formattedAmount)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(transaction.isIncome ? .green : .red)
                }
                
                HStack {
                    Text(transaction.category)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(.secondary.opacity(0.2), in: RoundedRectangle(cornerRadius: 6))
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                        .font(.caption)
                    
                    Text(transaction.accountName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(DateFormatter.shortDate.string(from: transaction.date))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.ultraThinMaterial, lineWidth: 1)
        )
    }
}
