// UpcomingPaymentsSection.swift
// Sección de próximos pagos

import SwiftUI

struct UpcomingPaymentsSection: View {
    let subscriptions: [Subscription]
    
    var upcomingPayments: [Subscription] {
        subscriptions
            .filter { $0.isActive && $0.nextPaymentDate != nil }
            .sorted { ($0.nextPaymentDate ?? Date()) < ($1.nextPaymentDate ?? Date()) }
            .prefix(3)
            .map { $0 }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Próximos pagos")
                .font(.headline)
            
            VStack(spacing: 8) {
                ForEach(upcomingPayments) { subscription in
                    HStack {
                        Circle()
                            .fill(getPaymentColor(subscription.nextPaymentDate))
                            .frame(width: 8, height: 8)
                        
                        Text(subscription.name ?? "")
                            .font(.subheadline)
                        
                        Spacer()
                        
                        if let date = subscription.nextPaymentDate {
                            Text(formatDate(date))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Text(subscription.amount.formatted(.currency(code: "MXN")))
                            .font(.subheadline.bold())
                    }
                    
                    if subscription != upcomingPayments.last {
                        Divider()
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Material.liquidGlass.opacity(0.5))
            )
        }
    }
    
    private func getPaymentColor(_ date: Date?) -> Color {
        guard let date = date else { return .gray }
        let days = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
        
        if days <= 1 {
            return .red
        } else if days <= 3 {
            return .orange
        } else {
            return .green
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        formatter.locale = Locale(identifier: "es_MX")
        return formatter.string(from: date)
    }
}
