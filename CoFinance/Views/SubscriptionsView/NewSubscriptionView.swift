import SwiftUI

// MARK: - NEW SUBSCRIPTION VIEW
struct NewSubscriptionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var coreDataManager: CoreDataManager
    @Environment(\.currencyFormatter) private var currencyFormatter
    
    let onSaved: () -> Void
    
    @State private var name = ""
    @State private var amount = ""
    @State private var frequency: SubscriptionFrequency = .mensual
    @State private var intervalDays: String = "30"
    @State private var nextChargeDate = Date()
    @State private var selectedAccount = ""
    @State private var selectedCategory = "Servicios"
    @State private var notes = ""
    @State private var isActive = true
    
    @State private var showingAccountPicker = false
    @State private var showingCategoryPicker = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Preview
                HStack(spacing: 12) {
                    Circle()
                        .fill(.orange)
                        .frame(width: 50, height: 50)
                        .overlay(
                            Image(systemName: "repeat.circle.fill")
                                .foregroundColor(.white)
                                .font(.title3)
                        )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(name.isEmpty ? "Nueva Suscripción" : name)
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("Próximo: \(DateFormatter.mediumDate.string(from: nextChargeDate))")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    Text(currencyFormatter.string(from: NSNumber(value: Double(amount) ?? 0.0)) ?? "$0.00")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .padding(16)
                .background(
                    LinearGradient(gradient: Gradient(colors: [.orange, .orange.opacity(0.5)]), startPoint: .leading, endPoint: .trailing),
                    in: RoundedRectangle(cornerRadius: 20)
                )
                .shadow(color: Color.orange.opacity(0.3), radius: 8, x: 0, y: 4)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Form
                        VStack(spacing: 1) {
                            // Nombre
                            labeledField(icon: "textformat", title: "Nombre") {
                                TextField("Ej: Netflix", text: $name)
                                    .multilineTextAlignment(.trailing)
                                    .foregroundColor(.secondary)
                            }
                            
                            Divider().padding(.leading, 60)
                            
                            // Monto
                            labeledField(icon: "dollarsign.circle.fill", title: "Monto") {
                                TextField("0.00", text: $amount)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .foregroundColor(.secondary)
                                    .numericOnly($amount, includeDecimal: true)
                            }
                            
                            Divider().padding(.leading, 60)
                            
                            // Frecuencia
                            Menu {
                                ForEach(SubscriptionFrequency.allCases) { freq in
                                    Button(freq.displayName) {
                                        frequency = freq
                                    }
                                }
                            } label: {
                                labeledRow(icon: "repeat", title: "Frecuencia") {
                                    HStack(spacing: 6) {
                                        Text(frequency.displayName)
                                            .foregroundColor(.secondary)
                                        Image(systemName: "chevron.down")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .background(.regularMaterial)
                            
                            if frequency == .personalizado {
                                Divider().padding(.leading, 60)
                                // Intervalo días
                                labeledField(icon: "calendar.badge.clock", title: "Cada (días)") {
                                    TextField("30", text: $intervalDays)
                                        .keyboardType(.numberPad)
                                        .multilineTextAlignment(.trailing)
                                        .foregroundColor(.secondary)
                                        .numericOnly($intervalDays, includeDecimal: false)
                                }
                            }
                            
                            Divider().padding(.leading, 60)
                            
                            // Fecha próxima
                            labeledRow(icon: "calendar", title: "Próximo cobro") {
                                DatePicker("", selection: $nextChargeDate, displayedComponents: .date)
                                    .labelsHidden()
                            }
                            
                            Divider().padding(.leading, 60)
                            
                            // Cuenta
                            Button { showingAccountPicker = true } label: {
                                labeledRow(icon: "creditcard.fill", title: "Cuenta") {
                                    HStack(spacing: 6) {
                                        Text(selectedAccount.isEmpty ? "Seleccionar" : selectedAccount)
                                            .foregroundColor(selectedAccount.isEmpty ? .red : .secondary)
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                            
                            Divider().padding(.leading, 60)
                            
                            // Categoría
                            Button { showingCategoryPicker = true } label: {
                                labeledRow(icon: "square.grid.2x2", title: "Categoría") {
                                    HStack(spacing: 6) {
                                        Text(selectedCategory)
                                            .foregroundColor(.secondary)
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                            
                            Divider().padding(.leading, 60)
                            
                            // Activa
                            labeledRow(icon: "bolt.badge.a", title: "Activa") {
                                Toggle("", isOn: $isActive)
                                    .labelsHidden()
                            }
                            
                            Divider().padding(.leading, 60)
                            
                            // Notas
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 16) {
                                    Image(systemName: "note.text")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .frame(width: 24)
                                    Text("Notas")
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    Spacer()
                                }
                                TextField("Notas (opcional)", text: $notes, axis: .vertical)
                                    .lineLimit(2...4)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(.regularMaterial)
                        }
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(.ultraThinMaterial, lineWidth: 1))
                        .padding(.horizontal, 20)
                        
                        // Guardar
                        Button {
                            let _ = coreDataManager.saveSubscription(
                                name: name,
                                amount: Double(amount) ?? 0.0,
                                frequency: frequency,
                                intervalDays: Int(intervalDays) ?? 30,
                                nextChargeDate: nextChargeDate,
                                accountName: selectedAccount,
                                category: selectedCategory,
                                notes: notes.isEmpty ? nil : notes,
                                isActive: isActive
                            )
                            onSaved()
                            dismiss()
                        } label: {
                            Text("Crear Suscripción")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(gradient: Gradient(colors: [.blue, .cyan]), startPoint: .leading, endPoint: .trailing),
                                    in: RoundedRectangle(cornerRadius: 16)
                                )
                        }
                        .buttonStyle(.plain)
                        .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                        .padding(.horizontal, 20)
                        .disabled(name.isEmpty || amount.isEmpty || selectedAccount.isEmpty)
                        .opacity((name.isEmpty || amount.isEmpty || selectedAccount.isEmpty) ? 0.6 : 1.0)
                        
                        Spacer(minLength: 50)
                    }
                }
            }
            .background(.ultraThinMaterial)
            .navigationTitle("Nueva Suscripción")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") { dismiss() }
                }
            }
        }
        .sheet(isPresented: $showingAccountPicker) {
            AccountPickerView(selectedAccount: $selectedAccount)
        }
        .sheet(isPresented: $showingCategoryPicker) {
            CategoryPickerView(
                selectedCategory: $selectedCategory,
                categories: TransactionCategory.Expense.all, // Reutilizamos categorías de gasto
                isIncome: false
            )
        }
    }
    
    // MARK: - UI helpers
    private func labeledField<Content: View>(icon: String, title: String, @ViewBuilder content: () -> Content) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 24)
            Text(title)
                .font(.body)
                .foregroundColor(.primary)
            Spacer()
            content()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(.regularMaterial)
    }
    
    private func labeledRow<Content: View>(icon: String, title: String, @ViewBuilder content: () -> Content) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 24)
            Text(title)
                .font(.body)
                .foregroundColor(.primary)
            Spacer()
            content()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(.regularMaterial)
    }
}

