import SwiftUI

// MARK: - TRANSACTION ROW VIEW (Para Home y vistas principales)
struct TransactionRowView: View {
    let transaction: Transaction
    @EnvironmentObject var settings: SettingsManager
    
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
                Text(formatAmount(transaction.amount, isIncome: transaction.isIncome))
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
    
    private func formatAmount(_ amount: Double, isIncome: Bool) -> String {
        let sign = isIncome ? "+" : ""
        return sign + settings.formatCurrency(amount)
    }
}

// MARK: - TRANSACTION ROW DETAILED VIEW (Para lista de transacciones)
struct TransactionRowDetailedView: View {
    let transaction: Transaction
    @EnvironmentObject var settings: SettingsManager
    
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
                    
                    Text(formatAmount(transaction.amount, isIncome: transaction.isIncome))
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
    
    private func formatAmount(_ amount: Double, isIncome: Bool) -> String {
        let sign = isIncome ? "+" : ""
        return sign + settings.formatCurrency(amount)
    }
}

// MARK: - MODERN TRANSACTION CARD (Para TransactionsView)
struct ModernTransactionCard: View {
    let transaction: Transaction
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.appTheme) private var theme
    @State private var isVisible = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Enhanced icon
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            transaction.isIncome ? Color.green : Color.red,
                            transaction.isIncome ? Color.green.opacity(0.7) : Color.red.opacity(0.7)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 48, height: 48)
                .overlay(
                    Image(systemName: transaction.categoryIcon)
                        .foregroundStyle(.white)
                        .font(.title3)
                )
                .shadow(
                    color: (transaction.isIncome ? Color.green : Color.red).opacity(0.3),
                    radius: 6,
                    x: 0,
                    y: 3
                )
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(transaction.name)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(formatTransactionAmount(transaction.amount))
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(transaction.isIncome ? Color.green : Color.red)
                        .contentTransition(.numericText())
                }
                
                HStack {
                    Text(transaction.category)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            Color.secondary.opacity(0.2),
                            in: RoundedRectangle(cornerRadius: 6)
                        )
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                        .font(.caption)
                    
                    Text(transaction.accountName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(DateFormatter.shortDate.string(from: transaction.date))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.thinMaterial)
                .stroke(.ultraThinMaterial, lineWidth: 1)
        )
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 10)
        .animation(.smooth(duration: 0.4), value: isVisible)
        .onAppear {
            withAnimation {
                isVisible = true
            }
        }
        .contentShape(Rectangle())
    }
    
    private func formatTransactionAmount(_ amount: Double) -> String {
        let sign = transaction.isIncome ? "+" : ""
        return sign + settings.formatCurrency(amount)
    }
}	
