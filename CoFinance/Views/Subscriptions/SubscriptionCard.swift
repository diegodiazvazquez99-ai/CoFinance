// SubscriptionCard.swift
// Tarjeta de suscripción

import SwiftUI

struct SubscriptionCard: View {
    let subscription: Subscription
    
    var body: some View {
        HStack(spacing: 12) {
            // Icono o logo
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(getServiceColor().opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: getServiceIcon())
                    .font(.title2)
                    .foregroundStyle(getServiceColor())
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(subscription.name ?? "Sin nombre")
                    .font(.headline)
                
                HStack(spacing: 4) {
                    Text(subscription.amount.formatted(.currency(code: "MXN")))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text("/ \(subscription.billingCycle ?? "mes")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                if let nextPayment = subscription.nextPaymentDate {
                    Text(daysUntilPayment(nextPayment))
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(getPaymentStatusColor(nextPayment).opacity(0.1))
                        )
                        .foregroundStyle(getPaymentStatusColor(nextPayment))
                }
                
                if !subscription.isActive {
                    Text("Pausada")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Material.liquidGlass)
        )
        .opacity(subscription.isActive ? 1.0 : 0.6)
    }
    
    private func getServiceIcon() -> String {
        switch subscription.category {
        case "streaming": return "tv.fill"
        case "software": return "desktopcomputer"
        case "fitness": return "figure.run"
        case "news": return "newspaper.fill"
        default: return "star.fill"
        }
    }
    
    private func getServiceColor() -> Color {
        switch subscription.category {
        case "streaming": return .purple
        case "software": return .blue
        case "fitness": return .green
        case "news": return .orange
        default: return .gray
        }
    }
    
    private func daysUntilPayment(_ date: Date) -> String {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
        if days == 0 {
            return "Hoy"
        } else if days == 1 {
            return "Mañana"
        } else if days < 0 {
            return "Vencido"
        } else {
            return "En \(days) días"
        }
    }
    
    private func getPaymentStatusColor(_ date: Date) -> Color {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
        if days <= 0 {
            return .red
        } else if days <= 3 {
            return .orange
        } else {
            return .green
        }
    }
}
