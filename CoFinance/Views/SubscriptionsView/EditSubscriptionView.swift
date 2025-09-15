import SwiftUI

// MARK: - EDIT SUBSCRIPTION VIEW
struct EditSubscriptionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var coreDataManager: CoreDataManager
    let subscription: Subscription
    let onSave: (Subscription) -> Void
    let onDelete: () -> Void
    
    @State private var name: String
    @State private var amount: String
    @State private var frequency: SubscriptionFrequency
    @State private var intervalDays: String
    @State private var nextChargeDate: Date
    @State private var selectedAccount: String
    @State private var selectedCategory: String
    @State private var notes: String
    @State private var isActive: Bool
    @State private var showingDeleteAlert = false
    @State private var showingAccountPicker = false
    @State private var showingCategoryPicker = false
    
    init(subscription: Subscription, onSave: @escaping (Subscription) -> Void, onDelete: @escaping () -> Void) {
        self.subscription = subscription
        self.onSave = onSave
        self.onDelete = onDelete
        
        _name = State(initialValue: subscription.name)
        _amount = State(initialValue: String(subscription.amount))
        _frequency = State(initialValue: subscription.frequency)
        _intervalDays = State(initialValue: String(subscription.intervalDays))
        _nextChargeDate = State(initialValue: subscription.nextChargeDate)
        _selectedAccount = State(initialValue: subscription.accountName)
        _selectedCategory = State(initialValue: subscription.category)
        _notes = State(initialValue: subscription.notes ?? "")
        _isActive = State(initialValue: subscription.isActive)
    }
    
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
                        Text(name.isEmpty ? "Suscripción" : name)
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("Próximo: \(DateFormatter.mediumDate.string(from: nextChargeDate))")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    Text("$\(amount.isEmpty ? "0.00" : amount)")
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
                        VStack(spacing: 1) {
                            labeledField(icon: "textformat", title: "Nombre") {
                                TextField("Nombre", text: $name)
                                    .multilineTextAlignment(.trailing)
                                    .foregroundColor(.secondary)
                            }
                            
                            Divider().padding(.leading, 60)
                            
                            labeledField(icon: "dollarsign.circle.fill", title: "Monto") {
                                TextField("0.00", text: $amount)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .foregroundColor(.secondary)
                                    .numericOnly($amount, includeDecimal: true)
                            }
                            
                            Divider().padding(.leading, 60)
                            
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
                                labeledField(icon: "calendar.badge.clock", title: "Cada (días)") {
                                    TextField("30", text: $intervalDays)
                                        .keyboardType(.numberPad)
                                        .multilineTextAlignment(.trailing)
                                        .foregroundColor(.secondary)
                                        .numericOnly($intervalDays, includeDecimal: false)
                                }
                            }
                            
                            Divider().padding(.leading, 60)
                            
                            labeledRow(icon: "calendar", title: "Próximo cobro") {
                                DatePicker("", selection: $nextChargeDate, displayedComponents: .date)
                                    .labelsHidden()
                            }
                            
                            Divider().padding(.leading, 60)
                            
                            Button { showingAccountPicker = true } label: {
                                labeledRow(icon: "creditcard.fill", title: "Cuenta") {
                                    HStack(spacing: 6) {
                                        Text(selectedAccount)
                                            .foregroundColor(.secondary)
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                            
                            Divider().padding(.leading, 60)
                            
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
                            
                            labeledRow(icon: "bolt.badge.a", title: "Activa") {
                                Toggle("", isOn: $isActive)
                                    .labelsHidden()
                            }
                            
                            Divider().padding(.leading, 60)
                            
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
                                    .lineLimit(3...6)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(.regularMaterial)
                        }
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(.ultraThinMaterial, lineWidth: 1))
                        .padding(.horizontal, 20)
                        
                        VStack(spacing: 16) {
                            Button {
                                let updated = Subscription(
                                    id: subscription.id,
                                    name: name,
                                    amount: Double(amount) ?? 0.0,
                                    frequency: frequency,
                                    intervalDays: Int(intervalDays) ?? 30,
                                    nextChargeDate: nextChargeDate,
                                    accountName: selectedAccount,
                                    category: selectedCategory,
                                    notes: notes.isEmpty ? nil : notes,
                                    isActive: isActive,
                                    createdAt: subscription.createdAt
                                )
                                onSave(updated)
                                dismiss()
                            } label: {
                                Text("Guardar Cambios")
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
                            .disabled(name.isEmpty || amount.isEmpty || selectedAccount.isEmpty)
                            .opacity((name.isEmpty || amount.isEmpty || selectedAccount.isEmpty) ? 0.6 : 1.0)
                            
                            Button {
                                showingDeleteAlert = true
                            } label: {
                                Text("Eliminar Suscripción")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
                                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(.red.opacity(0.3), lineWidth: 1))
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 50)
                    }
                }
            }
            .background(.ultraThinMaterial)
            .navigationTitle("Editar Suscripción")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") { dismiss() }
                }
            }
        }
        .alert("Eliminar Suscripción", isPresented: $showingDeleteAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Eliminar", role: .destructive) {
                onDelete()
                dismiss()
            }
        } message: {
            Text("¿Seguro que deseas eliminar esta suscripción? Esta acción no se puede deshacer.")
        }
        .sheet(isPresented: $showingAccountPicker) {
            AccountPickerView(selectedAccount: $selectedAccount)
        }
        .sheet(isPresented: $showingCategoryPicker) {
            CategoryPickerView(
                selectedCategory: $selectedCategory,
                categories: TransactionCategory.Expense.all,
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
            Text(title).font(.body).foregroundColor(.primary)
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
            Text(title).font(.body).foregroundColor(.primary)
            Spacer()
            content()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(.regularMaterial)
    }
}

