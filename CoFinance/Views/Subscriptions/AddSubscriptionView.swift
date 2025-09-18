// AddSubscriptionView.swift
// Vista para agregar nueva suscripción

import SwiftUI

struct AddSubscriptionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var amount = ""
    @State private var billingCycle = "Mensual"
    @State private var category = "streaming"
    @State private var startDate = Date()
    @State private var reminder = true
    
    let billingCycles = ["Semanal", "Mensual", "Anual"]
    let categories = [
        "streaming": "Streaming",
        "software": "Software",
        "fitness": "Fitness",
        "news": "Noticias",
        "other": "Otro"
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Información básica") {
                    TextField("Nombre del servicio", text: $name)
                    
                    HStack {
                        Text("$")
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                    }
                    
                    Picker("Ciclo de facturación", selection: $billingCycle) {
                        ForEach(billingCycles, id: \.self) { cycle in
                            Text(cycle).tag(cycle)
                        }
                    }
                }
                
                Section("Detalles") {
                    Picker("Categoría", selection: $category) {
                        ForEach(categories.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                            Label(value, systemImage: getCategoryIcon(key))
                                .tag(key)
                        }
                    }
                    
                    DatePicker("Fecha de inicio", selection: $startDate, displayedComponents: .date)
                    
                    Toggle("Recordatorio de pago", isOn: $reminder)
                }
            }
            .navigationTitle("Nueva Suscripción")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Guardar") {
                        saveSubscription()
                    }
                    .disabled(name.isEmpty || amount.isEmpty)
                }
            }
        }
    }
    
    private func getCategoryIcon(_ category: String) -> String {
        switch category {
        case "streaming": return "tv.fill"
        case "software": return "desktopcomputer"
        case "fitness": return "figure.run"
        case "news": return "newspaper.fill"
        default: return "star.fill"
        }
    }
    
    private func saveSubscription() {
        let subscription = Subscription(context: viewContext)
        subscription.id = UUID()
        subscription.name = name
        subscription.amount = Double(amount) ?? 0
        subscription.billingCycle = billingCycle
        subscription.category = category
        subscription.startDate = startDate
        subscription.nextPaymentDate = calculateNextPaymentDate()
        subscription.isActive = true
        subscription.reminder = reminder
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Error saving subscription: \(error)")
        }
    }
    
    private func calculateNextPaymentDate() -> Date {
        let calendar = Calendar.current
        switch billingCycle {
        case "Semanal":
            return calendar.date(byAdding: .day, value: 7, to: startDate) ?? startDate
        case "Anual":
            return calendar.date(byAdding: .year, value: 1, to: startDate) ?? startDate
        default: // Mensual
            return calendar.date(byAdding: .month, value: 1, to: startDate) ?? startDate
        }
    }
}
