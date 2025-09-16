import SwiftUI
import Combine

// MARK: - EDIT TRANSACTION VIEW
struct EditTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var coreDataManager: CoreDataManager
    let transaction: Transaction
    let onSave: (Transaction) -> Void
    let onDelete: (Transaction) -> Void
    
    @State private var transactionName: String
    @State private var amount: String
    @State private var isIncome: Bool
    @State private var selectedAccount: String
    @State private var selectedDate: Date
    @State private var selectedCategory: String
    @State private var notes: String
    @State private var showingDeleteAlert = false
    @State private var showingAccountPicker = false
    @State private var showingCategoryPicker = false
    
    init(transaction: Transaction, onSave: @escaping (Transaction) -> Void, onDelete: @escaping (Transaction) -> Void) {
        self.transaction = transaction
        self.onSave = onSave
        self.onDelete = onDelete
        self._transactionName = State(initialValue: transaction.name)
        self._amount = State(initialValue: String(transaction.amount))
        self._isIncome = State(initialValue: transaction.isIncome)
        self._selectedAccount = State(initialValue: transaction.accountName)
        self._selectedDate = State(initialValue: transaction.date)
        self._selectedCategory = State(initialValue: transaction.category)
        self._notes = State(initialValue: transaction.notes ?? "")
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
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
                        Text(transactionName.isEmpty ? "Transacción" : transactionName)
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
                                
                                TextField("Nombre", text: $transactionName)
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
                            
                            // Tipo (Ingreso/Egreso)
                            HStack(spacing: 16) {
                                Image(systemName: "arrow.up.arrow.down")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 24)
                                
                                Text("Tipo")
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                HStack(spacing: 12) {
                                    Button(action: {
                                        isIncome = false
                                        selectedCategory = TransactionCategory.Expense.other
                                    }) {
                                        Text("Egreso")
                                            .font(.caption)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(isIncome ? .clear : .red.opacity(0.2), in: RoundedRectangle(cornerRadius: 6))
                                            .foregroundColor(isIncome ? .secondary : .red)
                                    }
                                    
                                    Button(action: {
                                        isIncome = true
                                        selectedCategory = TransactionCategory.Income.other
                                    }) {
                                        Text("Ingreso")
                                            .font(.caption)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(isIncome ? .green.opacity(0.2) : .clear, in: RoundedRectangle(cornerRadius: 6))
                                            .foregroundColor(isIncome ? .green : .secondary)
                                    }
                                }
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
                                    
                                    Text(selectedAccount)
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
                                    .lineLimit(3...6)
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
                        
                        // MARK: - Botones de acción
                        VStack(spacing: 16) {
                            // Botón guardar cambios
                            Button(action: {
                                let updatedTransaction = Transaction(
                                    id: transaction.id,
                                    name: transactionName,
                                    amount: Double(amount) ?? 0.0,
                                    isIncome: isIncome,
                                    accountName: selectedAccount,
                                    category: selectedCategory,
                                    date: selectedDate,
                                    notes: notes.isEmpty ? nil : notes
                                )
                                onSave(updatedTransaction)
                                dismiss()
                            }) {
                                Text("Guardar Cambios")
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
                            .disabled(transactionName.isEmpty || amount.isEmpty)
                            .opacity((transactionName.isEmpty || amount.isEmpty) ? 0.6 : 1.0)
                            
                            // Botón eliminar transacción
                            Button(action: { showingDeleteAlert = true }) {
                                Text("Eliminar Transacción")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(.red.opacity(0.3), lineWidth: 1)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 50)
                    }
                }
            }
            .background(.ultraThinMaterial)
            .navigationTitle("Editar Transacción")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") { dismiss() }
                }
            }
        }
        .alert("Eliminar Transacción", isPresented: $showingDeleteAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Eliminar", role: .destructive) {
                onDelete(transaction)
                dismiss()
            }
        } message: {
            Text("¿Estás seguro de que quieres eliminar esta transacción? Esta acción no se puede deshacer.")
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
    
    private func getCategoryIcon() -> String {
        return TransactionCategory.icon(for: selectedCategory, isIncome: isIncome)
    }
}
