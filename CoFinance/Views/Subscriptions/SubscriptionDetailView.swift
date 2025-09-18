// MARK: - SubscriptionDetailView.swift
// Vista de detalle de suscripción

import SwiftUI

struct SubscriptionDetailView: View {
    let subscription: Subscription
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @State private var isEditing = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header con información principal
                    VStack(spacing: 12) {
                        Image(systemName: getCategoryIcon())
                            .font(.system(size: 60))
                            .foregroundStyle(getCategoryColor())
                            .frame(width: 100, height: 100)
                            .background(
                                Circle()
                                    .fill(getCategoryColor().opacity(0.1))
                            )
                        
                        Text(subscription.name ?? "")
                            .font(.title.bold())
                        
                        Text(subscription.amount.formatted(.currency(code: "MXN")))
                            .font(.largeTitle.bold())
                            .foregroundStyle(getCategoryColor())
                        
                        Text("/ \(subscription.billingCycle ?? "mes")")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    
                    // Información de pago
                    GroupBox("Información de pago") {
                        VStack(spacing: 12) {
                            DetailRow(
                                label: "Próximo pago",
                                value: formatDate(subscription.nextPaymentDate ?? Date())
                            )
                            
                            DetailRow(
                                label: "Inicio de suscripción",
                                value: formatDate(subscription.startDate ?? Date())
                            )
                            
                            DetailRow(
                                label: "Estado",
                                value: subscription.isActive ? "Activa" : "Pausada",
                                valueColor: subscription.isActive ? .green : .orange
                            )
                            
                            DetailRow(
                                label: "Recordatorios",
                                value: subscription.reminder ? "Activados" : "Desactivados"
                            )
                        }
                    }
                    
                    // Historial de pagos
                    GroupBox("Historial de pagos") {
                        if let transactions = subscription.transactions?.allObjects as? [Transaction], !transactions.isEmpty {
                            ForEach(transactions.sorted(by: { ($0.date ?? Date()) > ($1.date ?? Date()) }).prefix(5)) { transaction in
                                HStack {
                                    Text(formatDate(transaction.date ?? Date()))
                                        .font(.subheadline)
                                    Spacer()
                                    Text(transaction.amount.formatted(.currency(code: "MXN")))
                                        .font(.subheadline.bold())
                                }
                                if transaction != transactions.last {
                                    Divider()
                                }
                            }
                        } else {
                            Text("Sin historial de pagos")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical)
                        }
                    }
                    
                    // Estadísticas
                    GroupBox("Estadísticas") {
                        HStack(spacing: 20) {
                            StatisticView(
                                value: calculateTotalSpent(),
                                label: "Total gastado",
                                icon: "dollarsign.circle.fill",
                                color: .blue
                            )
                            
                            StatisticView(
                                value: calculateAnnualCost(),
                                label: "Costo anual",
                                icon: "calendar.circle.fill",
                                color: .purple
                            )
                        }
                    }
                    
                    // Notas
                    if let notes = subscription.notes, !notes.isEmpty {
                        GroupBox("Notas") {
                            Text(notes)
                                .font(.subheadline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    
                    // Acciones
                    VStack(spacing: 12) {
                        Button {
                            toggleSubscriptionStatus()
                        } label: {
                            Label(
                                subscription.isActive ? "Pausar suscripción" : "Activar suscripción",
                                systemImage: subscription.isActive ? "pause.circle.fill" : "play.circle.fill"
                            )
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(subscription.isActive ? Color.orange.opacity(0.1) : Color.green.opacity(0.1))
                            )
                            .foregroundStyle(subscription.isActive ? .orange : .green)
                        }
                        
                        Button(role: .destructive) {
                            deleteSubscription()
                        } label: {
                            Label("Eliminar suscripción", systemImage: "trash.fill")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.red.opacity(0.1))
                                )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Detalle de suscripción")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Editar") {
                        isEditing = true
                    }
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            // EditSubscriptionView
        }
    }
    
    private func getCategoryIcon() -> String {
        switch subscription.category {
        case "streaming": return "tv.fill"
        case "software": return "desktopcomputer"
        case "fitness": return "figure.run"
        case "news": return "newspaper.fill"
        default: return "star.fill"
        }
    }
    
    private func getCategoryColor() -> Color {
        switch subscription.category {
        case "streaming": return .purple
        case "software": return .blue
        case "fitness": return .green
        case "news": return .orange
        default: return .gray
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "es_MX")
        return formatter.string(from: date)
    }
    
    private func calculateTotalSpent() -> String {
        guard let transactions = subscription.transactions?.allObjects as? [Transaction] else {
            return "$0"
        }
        let total = transactions.reduce(0) { $0 + abs($1.amount) }
        return total.formatted(.currency(code: "MXN"))
    }
    
    private func calculateAnnualCost() -> String {
        let monthlyAmount: Double
        switch subscription.billingCycle {
        case "Semanal":
            monthlyAmount = subscription.amount * 4.33
        case "Anual":
            monthlyAmount = subscription.amount / 12
        default:
            monthlyAmount = subscription.amount
        }
        let annual = monthlyAmount * 12
        return annual.formatted(.currency(code: "MXN"))
    }
    
    private func toggleSubscriptionStatus() {
        subscription.isActive.toggle()
        try? viewContext.save()
        dismiss()
    }
    
    private func deleteSubscription() {
        viewContext.delete(subscription)
        try? viewContext.save()
        dismiss()
    }
}
