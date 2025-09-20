// CompactTransactionRow.swift
// Fila compacta de transacción

import SwiftUI

struct CompactTransactionRow: View {
let transaction: Transaction
@State private var isPressed = false

```
var body: some View {
    HStack {
        // Icono con color de tipo
        Image(systemName: getIcon())
            .font(.caption)
            .foregroundStyle(getColor())
            .frame(width: 24, height: 24)
            .background(
                Circle()
                    .fill(getColor().opacity(0.1))
            )
        
        VStack(alignment: .leading, spacing: 2) {
            Text(transaction.title ?? "Sin título")
                .font(.subheadline)
                .lineLimit(1)
            
            HStack(spacing: 4) {
                Text(formatDate(transaction.date ?? Date()))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                
                if let category = transaction.category, !category.isEmpty {
                    Text("•")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    
                    Text(category)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }
        
        Spacer()
        
        VStack(alignment: .trailing, spacing: 0) {
            Text(transaction.amount.formatted(.currency(code: "MXN")))
                .font(.subheadline.bold())
                .foregroundStyle(transaction.amount < 0 ? .red : .green)
            
            if let account = transaction.account {
                Text(account.name ?? "")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
    .padding(.vertical, 4)
    .scaleEffect(isPressed ? 0.98 : 1.0)
    .onLongPressGesture(
        minimumDuration: 0.1,
        maximumDistance: .infinity,
        pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
            if pressing {
                HapticManager.shared.softTouch()
            }
        },
        perform: {
            // Acción al mantener presionado
        }
    )
}

private func getIcon() -> String {
    guard let type = transaction.type else { return "circle" }
    return TransactionType(rawValue: type)?.icon ?? "circle"
}

private func getColor() -> Color {
    guard let type = transaction.type else { return .gray }
    return TransactionType(rawValue: type)?.color ?? .gray
}

private func formatDate(_ date: Date) -> String {
    if date.isToday {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "Hoy, \(formatter.string(from: date))"
    } else if date.isYesterday {
        return "Ayer"
    } else if date.isThisWeek {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        formatter.locale = Locale(identifier: "es_MX")
        return formatter.string(from: date).capitalizedFirst
    } else {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        formatter.locale = Locale(identifier: "es_MX")
        return formatter.string(from: date)
    }
}
```

}