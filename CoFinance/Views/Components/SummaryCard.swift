// SummaryCard.swift
// Tarjeta de resumen compacta

import SwiftUI

struct SummaryCard: View {
let title: String
let amount: Double
let icon: String
let color: Color
var trend: Double? = nil
var showTrend: Bool = true

```
var body: some View {
    VStack(spacing: 8) {
        HStack {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(color)
            
            Spacer()
            
            if showTrend, let trend = trend {
                TrendIndicator(value: trend)
            }
        }
        
        Text(title)
            .font(.caption)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
        
        Text(abs(amount).formatted(.currency(code: "MXN")))
            .font(.subheadline.bold())
            .foregroundStyle(title == "Diferencia" && amount < 0 ? .red : .primary)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 12)
    .padding(.horizontal, 12)
    .background(
        RoundedRectangle(cornerRadius: 12)
            .fill(Material.liquidGlass)
    )
}
```

}

// MARK: - Trend Indicator
struct TrendIndicator: View {
let value: Double

```
var trendColor: Color {
    if value > 0 {
        return .green
    } else if value < 0 {
        return .red
    } else {
        return .gray
    }
}

var trendIcon: String {
    if value > 0 {
        return "arrow.up.right"
    } else if value < 0 {
        return "arrow.down.right"
    } else {
        return "minus"
    }
}

var body: some View {
    HStack(spacing: 2) {
        Image(systemName: trendIcon)
            .font(.system(size: 8))
        Text("\(Int(abs(value)))%")
            .font(.system(size: 9))
    }
    .foregroundStyle(trendColor)
    .padding(.horizontal, 4)
    .padding(.vertical, 2)
    .background(
        Capsule()
            .fill(trendColor.opacity(0.1))
    )
}
```

}