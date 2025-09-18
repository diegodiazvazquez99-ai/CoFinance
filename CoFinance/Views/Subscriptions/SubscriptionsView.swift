// SubscriptionsView.swift
// Vista de Suscripciones

import SwiftUI

struct SubscriptionsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var viewModel: SubscriptionViewModel
    @State private var showingAddSubscription = false
    @State private var selectedSubscription: Subscription?
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Subscription.nextPaymentDate, ascending: true)],
        animation: .smooth
    ) private var subscriptions: FetchedResults<Subscription>
    
    var totalMonthlyAmount: Double {
        subscriptions.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Resumen de suscripciones
                    SubscriptionSummaryCard(
                        totalAmount: totalMonthlyAmount,
                        activeCount: subscriptions.count,
                        upcomingPayments: getUpcomingPayments()
                    )
                    .padding(.horizontal)
                    
                    // Lista de suscripciones
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Suscripciones activas")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if subscriptions.isEmpty {
                            EmptyStateView(
                                icon: "repeat.circle",
                                title: "Sin suscripciones",
                                message: "Agrega tus suscripciones para llevar un control de tus pagos recurrentes"
                            )
                            .padding()
                        } else {
                            ForEach(subscriptions) { subscription in
                                SubscriptionCard(subscription: subscription)
                                    .padding(.horizontal)
                                    .onTapGesture {
                                        selectedSubscription = subscription
                                    }
                                    .contextMenu { // iOS 13+
                                        Button {
                                            toggleSubscriptionStatus(subscription)
                                        } label: {
                                            Label(
                                                subscription.isActive ? "Pausar" : "Activar",
                                                systemImage: subscription.isActive ? "pause.circle" : "play.circle"
                                            )
                                        }
                                        
                                        Button(role: .destructive) {
                                            deleteSubscription(subscription)
                                        } label: {
                                            Label("Eliminar", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                    }
                    
                    // Próximos pagos
                    if !subscriptions.isEmpty {
                        UpcomingPaymentsSection(subscriptions: Array(subscriptions))
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Suscripciones")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Suscripciones")
                        .font(.largeTitle.bold())
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddSubscription.toggle()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
            .liquidGlassToolbar()
        }
        .sheet(isPresented: $showingAddSubscription) {
            AddSubscriptionView()
        }
        .sheet(item: $selectedSubscription) { subscription in
            SubscriptionDetailView(subscription: subscription)
                .presentationDetents([.medium, .large])
                .presentationBackground(Material.liquidGlass)
        }
    }
    
    private func getUpcomingPayments() -> Int {
        let calendar = Calendar.current
        let nextWeek = calendar.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        return subscriptions.filter { subscription in
            guard let nextPayment = subscription.nextPaymentDate else { return false }
            return nextPayment <= nextWeek
        }.count
    }
    
    private func toggleSubscriptionStatus(_ subscription: Subscription) {
        subscription.isActive.toggle()
        try? viewContext.save()
    }
    
    private func deleteSubscription(_ subscription: Subscription) {
        withAnimation {
            viewContext.delete(subscription)
            try? viewContext.save()
        }
    }
}
