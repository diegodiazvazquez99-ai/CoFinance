// BalanceChart.swift
// Gráfico de evolución del balance

import SwiftUI
import Charts

struct BalanceChart: View {
let transactions: [Transaction]
@State private var selectedDate: Date?
@State private var selectedBalance: Double?

```
var chartData: [(date: Date, balance: Double)] {
    var runningBalance = 0.0
    return transactions.reversed().map { transaction in
        runningBalance += transaction.amount
        return (date: transaction.date ?? Date(), balance: runningBalance)
    }
}

var minBalance: Double {
    chartData.map { $0.balance }.min() ?? 0
}

var maxBalance: Double {
    chartData.map { $0.balance }.max() ?? 0
}

var body: some View {
    VStack(alignment: .leading, spacing: 8) {
        HStack {
            Text("Evolución del balance")
                .font(.headline)
            
            Spacer()
            
            if let selectedDate = selectedDate, let selectedBalance = selectedBalance {
                VStack(alignment: .trailing, spacing: 2) {
                    Text(selectedBalance.formatted(.currency(code: "MXN")))
                        .font(.caption.bold())
                        .foregroundStyle(.primary)
                    Text(formatDate(selectedDate))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        
        Chart(chartData, id: \.date) { item in
            // Línea principal
            LineMark(
                x: .value("Fecha", item.date),
                y: .value("Balance", item.balance)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [.blue, .purple],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .interpolationMethod(.catmullRom)
            .lineStyle(StrokeStyle(lineWidth: 2))
            
            // Área bajo la curva
            AreaMark(
                x: .value("Fecha", item.date),
                y: .value("Balance", item.balance)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [
                        item.balance >= 0 ? Color.blue.opacity(0.3) : Color.red.opacity(0.3),
                        item.balance >= 0 ? Color.purple.opacity(0.1) : Color.red.opacity(0.1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .interpolationMethod(.catmullRom)
            
            // Punto para selección
            if let selectedDate = selectedDate, 
               Calendar.current.isDate(item.date, inSameDayAs: selectedDate) {
                PointMark(
                    x: .value("Fecha", item.date),
                    y: .value("Balance", item.balance)
                )
                .foregroundStyle(.blue)
                .symbolSize(100)
                
                RuleMark(x: .value("Fecha", item.date))
                    .foregroundStyle(.gray.opacity(0.3))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
            }
        }
        .frame(height: 160)
        .chartYScale(domain: (minBalance * 1.1)...(maxBalance * 1.1))
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 5)) { _ in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                    .font(.caption2)
            }
        }
        .chartYAxis {
            AxisMarks(values: .automatic(desiredCount: 4)) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let amount = value.as(Double.self) {
                        Text(formatCompactAmount(amount))
                            .font(.caption2)
                    }
                }
            }
        }
        .chartBackground { chartProxy in
            GeometryReader { geometry in
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .onTapGesture { location in
                        let xPosition = location.x - geometry.frame(in: .local).minX
                        if let date = chartProxy.value(atX: xPosition, as: Date.self) {
                            findClosestDataPoint(to: date)
                        }
                    }
            }
        }
        
        // Línea de cero
        if minBalance < 0 && maxBalance > 0 {
            Chart {
                RuleMark(y: .value("Cero", 0))
                    .foregroundStyle(.red.opacity(0.5))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
            }
            .frame(height: 160)
            .allowsHitTesting(false)
            .position(x: UIScreen.main.bounds.width / 2, y: 80)
        }
    }
    .padding()
    .background(
        RoundedRectangle(cornerRadius: 16)
            .fill(Material.liquidGlass)
    )
}

private func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "d MMM"
    formatter.locale = Locale(identifier: "es_MX")
    return formatter.string(from: date)
}

private func formatCompactAmount(_ amount: Double) -> String {
    if abs(amount) >= 1000000 {
        return String(format: "$%.1fM", amount / 1000000)
    } else if abs(amount) >= 1000 {
        return String(format: "$%.1fK", amount / 1000)
    } else {
        return String(format: "$%.0f", amount)
    }
}

private func findClosestDataPoint(to date: Date) {
    let closest = chartData.min(by: { abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date)) })
    
    withAnimation(.easeInOut(duration: 0.2)) {
        selectedDate = closest?.date
        selectedBalance = closest?.balance
    }
    
    HapticManager.shared.selection()
    
    // Limpiar selección después de 3 segundos
    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
        withAnimation {
            selectedDate = nil
            selectedBalance = nil
        }
    }
}
```

}