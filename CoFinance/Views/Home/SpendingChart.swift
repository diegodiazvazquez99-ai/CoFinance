// SpendingChart.swift
// Gráfico de gastos por categoría

import SwiftUI
import Charts

struct SpendingChart: View {
    @State private var chartData: [ChartData] = []
    
    struct ChartData: Identifiable {
        let id = UUID()
        let category: String
        let amount: Double
        let color: Color
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Gastos por categoría")
                .font(.headline)
                .padding(.horizontal)
            
            Chart(chartData) { item in
                SectorMark(
                    angle: .value("Monto", item.amount),
                    innerRadius: .ratio(0.5),
                    angularInset: 2
                )
                .foregroundStyle(item.color)
                .cornerRadius(8)
            }
            .frame(height: 160)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Material.liquidGlass)
            )
        }
        .onAppear {
            loadChartData()
        }
    }
    
    private func loadChartData() {
        // Datos de ejemplo
        chartData = [
            ChartData(category: "Comida", amount: 3500, color: .orange),
            ChartData(category: "Transporte", amount: 1200, color: .blue),
            ChartData(category: "Entretenimiento", amount: 800, color: .purple),
            ChartData(category: "Servicios", amount: 2000, color: .green),
            ChartData(category: "Otros", amount: 500, color: .gray)
        ]
    }
}
