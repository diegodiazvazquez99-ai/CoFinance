import SwiftUI

// MARK: - NEW TRANSACTION VIEW
struct NewTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var coreDataManager: CoreDataManager
    let onSave: (Transaction) -> Void
    
    @State private var isIncome = false
    @State private var transactionName = ""
    @State private var amount = ""
    @State private var selectedAccount = ""
    @State private var selectedDate = Date()
    @State private var selectedCategory = "Ninguna"
    @State private var notes = ""
    @State private var showingAccountPicker = false
    @State private var showingCategoryPicker = false
    @State private var accounts: [AccountEntity] = []
    
    var accountNames: [String] {
        accounts.map { $0.name ?? "" }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if accounts.isEmpty {
                    // Estado cuando no hay cuentas
                    VStack(spacing: 20) {
                        Image(systemName: "creditcard")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                        
                        Text("No hay cuentas")
                            .font(.title2)
                            .fontWeight(.medium)
                        
                        Text("Necesitas crear al menos una cuenta antes de agregar transacciones")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button("Ir a Cuentas") {
                            dismiss()
                        }
                        .font(.headline)
                        .foregroundColor(.blue)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, 20)
                } else {
                    // MARK: - Preview Card
                    HStack(spacing: 12) {
                        Circle()
                            .fill(isIncome ? .green : .red)
                            .frame(width: 50, height: 50)
                            .overlay(
                                Image(systemName: getCategoryIcon())
                                    .foregroundColor(.white)
                                    .font(.title3)
                            )
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(transactionName.isEmpty ? "Nueva Transacción" : transactionName)
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("\(selectedDate, formatter: DateFormatter.mediumDate)")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Spacer()
                        
                        Text("\(isIncome ? "+" : "")$\(amount.isEmpty ? "0.00" : amount)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .padding(16)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                isIncome ? Color.green : Color.red,
                                isIncome ? Color.green.opacity(0.5) : Color.red.opacity(0.5)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        in: RoundedRectangle(cornerRadius: 20)
                    )
                    .shadow(color: (isIncome ? Color.green : Color.red).opacity(0.3), radius: 8, x: 0, y: 4)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            // MARK: - Selector de tipo (Ingreso/Egreso)
                            HStack(spacing: 16) {
                                // Botón Egreso
                                Button(action: {
                                    isIncome = false
                                    selectedCategory = "Ninguna"
                                }) {
                                    VStack(alignment: .leading, spacing: 12) {
                                        HStack {
                                            Circle()
                                                .fill(Color.red)
                                                .frame(width: 40, height: 40)
                                                .overlay(
                                                    Image(systemName: "arrow.up")
                                                        .font(.title3)
                                                        .fontWeight(.semibold)
                                                        .foregroundColor(.white)
                                                )
                                                .shadow(color: Color.red.opacity(0.3), radius: 6, x: 0, y: 3)
                                            Spacer()
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Egreso")
                                                .font(.title2)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.primary)
                                            
                                            Text("Gastos y pagos")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .padding(16)
                                    .frame(maxWidth: .infinity, minHeight: 100, alignment: .leading)
                                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(.ultraThinMaterial, lineWidth: 1)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(isIncome ? Color.clear : Color.red.opacity(0.4), lineWidth: 2)
                                    )
                                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                                    .scaleEffect(isIncome ? 1.0 : 1.02)
                                }
                                .buttonStyle(.plain)
                                
                                // Botón Ingreso
                                Button(action: {
                                    isIncome = true
                                    selectedCategory = "Ninguna"
                                }) {
                                    VStack(alignment: .leading, spacing: 12) {
                                        HStack {
                                            Circle()
                                                .fill(Color.green)
                                                .frame(width: 40, height: 40)
                                                .overlay(
                                                    Image(systemName: "arrow.down")
                                                        .font(.title3)
                                                        .fontWeight(.semibold)
                                                        .foregroundColor(.white)
                                                )
                                                .shadow(color: Color.green.opacity(0.3), radius: 6, x: 0, y: 3)
                                            Spacer()
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Ingreso")
                                                .font(.title2)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.primary)
                                            
                                            Text("Salarios y ganancias")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .padding(16)
                                    .frame(maxWidth: .infinity, minHeight: 100, alignment: .leading)
                                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(.ultraThinMaterial, lineWidth: 1)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(isIncome ? Color.green.opacity(0.4) : Color.clear, lineWidth: 2)
                                    )
                                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                                    .scaleEffect(isIncome ? 1.02 : 1.0)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            
                            // MARK: - Formulario
                            VStack(spacing: 1) {
                                // Nombre
                                HStack(spacing: 16) {
                                    Image(systemName: "textformat")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .frame(width: 24)
                                    
                                    Text("Nombre")
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    TextField("Ej: Compra supermercado", text: $transactionName)
                                        .multilineTextAlignment(.trailing)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(.regularMaterial)
                                
                                Divider().padding(.leading, 60)
                                
                                // Monto
                                HStack(spacing: 16) {
                                    Image(systemName: "dollarsign.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .frame(width: 24)
                                    
                                    Text("Monto")
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    TextField("0.00", text: $amount)
                                        .keyboardType(.decimalPad)
                                        .multilineTextAlignment(.trailing)
                                        .foregroundColor(.secondary)
                                        .numericOnly($amount, includeDecimal: true)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(.regularMaterial)
                                
                                Divider().padding(.leading, 60)
                                
                                // Cuenta
                                Button(action: { showingAccountPicker = true }) {
                                    HStack(spacing: 16) {
                                        Image(systemName: "creditcard.fill")
                                            .font(.title2)
                                            .foregroundColor(.white)
                                            .frame(width: 24)
                                        
                                        Text("Cuenta")
                                            .font(.body)
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                        
                                        Text(selectedAccount.isEmpty ? "Seleccionar cuenta" : selectedAccount)
                                            .foregroundColor(selectedAccount.isEmpty ? .red : .secondary)
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 16)
                                }
                                .buttonStyle(.plain)
                                .background(.regularMaterial)
                                
                                Divider().padding(.leading, 60)
                                
                                // Fecha
                                HStack(spacing: 16) {
                                    Image(systemName: "calendar")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .frame(width: 24)
                                    
                                    Text("Fecha")
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    DatePicker("", selection: $selectedDate, displayedComponents: .date)
                                        .labelsHidden()
                                        .accentColor(.blue)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(.regularMaterial)
                                
                                Divider().padding(.leading, 60)
                                
                                // Categoría
                                Button(action: { showingCategoryPicker = true }) {
                                    HStack(spacing: 16) {
                                        Image(systemName: "square.grid.2x2")
                                            .font(.title2)
                                            .foregroundColor(.white)
                                            .frame(width: 24)
                                        
                                        Text("Categoría")
                                            .font(.body)
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                        
                                        Text(selectedCategory)
                                            .foregroundColor(.secondary)
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 16)
                                }
                                .buttonStyle(.plain)
                                .background(.regularMaterial)
                                
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
                                    
                                    TextField("Notas adicionales (opcional)", text: $notes, axis: .vertical)
                                        .lineLimit(2...4)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(.regularMaterial)
                            }
                            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(.ultraThinMaterial, lineWidth: 1)
                            )
                            .padding(.horizontal, 20)
                            
                            // MARK: - Botón Guardar
                            Button(action: {
                                // 🔥 GUARDAR TRANSACCIÓN Y ACTUALIZAR BALANCE
                                let savedTransaction = coreDataManager.saveTransaction(
                                    name: transactionName,
                                    amount: Double(amount) ?? 0.0,
                                    isIncome: isIncome,
                                    accountName: selectedAccount,
                                    category: selectedCategory,
                                    date: selectedDate,
                                    notes: notes.isEmpty ? nil : notes
                                )
                                
                                if savedTransaction != nil {
                                    print("✅ Transacción guardada exitosamente")
                                    
                                    // Callback para notificar a la vista padre
                                    onSave(Transaction(
                                        name: transactionName,
                                        amount: Double(amount) ?? 0.0,
                                        isIncome: isIncome,
                                        accountName: selectedAccount,
                                        category: selectedCategory,
                                        date: selectedDate,
                                        notes: notes.isEmpty ? nil : notes
                                    ))
                                    
                                    dismiss()
                                } else {
                                    print("❌ Error al guardar transacción")
                                }
                            }) {
                                Text("Guardar Transacción")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [.blue, .cyan]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ),
                                        in: RoundedRectangle(cornerRadius: 16)
                                    )
                            }
                            .buttonStyle(.plain)
                            .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                            .padding(.horizontal, 20)
                            .disabled(amount.isEmpty || transactionName.isEmpty || selectedAccount.isEmpty)
                            .opacity((amount.isEmpty || transactionName.isEmpty || selectedAccount.isEmpty) ? 0.6 : 1.0)
                            
                            Spacer(minLength: 50)
                        }
                    }
                }
            }
            .background(.ultraThinMaterial)
            .navigationTitle("Nueva Transacción")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") { dismiss() }
                }
            }
        }
        .onAppear {
            print("🚀 NewTransactionView apareció - cargando cuentas...")
            loadAccounts()
        }
        .sheet(isPresented: $showingAccountPicker) {
            AccountPickerView(selectedAccount: $selectedAccount)
        }
        .sheet(isPresented: $showingCategoryPicker) {
            CategoryPickerView(
                selectedCategory: $selectedCategory,
                categories: TransactionCategory.categories(for: isIncome),
                isIncome: isIncome
            )
        }
    }
    
    private func loadAccounts() {
        accounts = coreDataManager.fetchAccounts()
        print("📝 NewTransactionView cargó \(accounts.count) cuentas: \(accounts.map { $0.name ?? "Sin nombre" })")
        
        // Si hay cuentas y no hay una seleccionada, seleccionar la primera
        if !accounts.isEmpty && selectedAccount.isEmpty {
            selectedAccount = accounts.first?.name ?? ""
            print("✅ Cuenta seleccionada automáticamente en NewTransaction: \(selectedAccount)")
        }
    }
    
    private func getCategoryIcon() -> String {
        if selectedCategory == "Ninguna" {
            return isIncome ? "arrow.down" : "arrow.up"
        }
        
        return TransactionCategory.icon(for: selectedCategory, isIncome: isIncome)
    }
}
