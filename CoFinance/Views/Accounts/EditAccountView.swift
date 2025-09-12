import SwiftUI

// MARK: - EDIT ACCOUNT VIEW
struct EditAccountView: View {
    @Environment(\.dismiss) private var dismiss
    let account: Account
    let onSave: (Account) -> Void
    let onDelete: (Account) -> Void
    
    @State private var accountName: String
    @State private var selectedType: String
    @State private var currentBalance: String
    @State private var selectedColor: String
    @State private var showingDeleteAlert = false
    
    init(account: Account, onSave: @escaping (Account) -> Void, onDelete: @escaping (Account) -> Void) {
        self.account = account
        self.onSave = onSave
        self.onDelete = onDelete
        self._accountName = State(initialValue: account.name)
        self._selectedType = State(initialValue: account.type)
        self._currentBalance = State(initialValue: String(account.balance))
        self._selectedColor = State(initialValue: account.color)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // MARK: - Preview Card
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Circle()
                            .fill(AccountColor.color(from: selectedColor))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: getTypeIcon())
                                    .font(.title3)
                                    .foregroundColor(.white)
                            )
                            .shadow(color: AccountColor.color(from: selectedColor).opacity(0.3), radius: 6, x: 0, y: 3)
                        Spacer()
                        
                        Text(selectedType)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(AccountColor.color(from: selectedColor).opacity(0.2), in: RoundedRectangle(cornerRadius: 8))
                            .foregroundColor(AccountColor.color(from: selectedColor))
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(accountName.isEmpty ? "Cuenta" : accountName)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("$\(currentBalance.isEmpty ? "0.00" : currentBalance)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor((Double(currentBalance) ?? 0) >= 0 ? .primary : .red)
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.ultraThinMaterial, lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // MARK: - Campos del formulario
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
                                
                                TextField("Nombre de cuenta", text: $accountName)
                                    .multilineTextAlignment(.trailing)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                            .background(.regularMaterial)
                            
                            Divider()
                                .padding(.leading, 60)
                            
                            // Tipo de cuenta
                            Menu {
                                ForEach(AccountType.all, id: \.self) { type in
                                    Button(type) {
                                        selectedType = type
                                    }
                                }
                            } label: {
                                HStack(spacing: 16) {
                                    Image(systemName: "wallet.pass.fill")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                        .frame(width: 24)
                                    
                                    Text("Tipo")
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Text(selectedType)
                                        .foregroundColor(.secondary)
                                    
                                    Image(systemName: "chevron.down")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                            }
                            .background(.regularMaterial)
                            
                            Divider()
                                .padding(.leading, 60)
                            
                            // Balance actual
                            HStack(spacing: 16) {
                                Image(systemName: "dollarsign.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 24)
                                
                                Text("Balance Actual")
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                TextField("0.00", text: $currentBalance)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .foregroundColor(.secondary)
                                    .numericOnly($currentBalance, includeDecimal: true)
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
                        
                        // MARK: - Selector de color
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Color de la cuenta")
                                .font(.headline)
                                .padding(.horizontal, 20)
                            
                            HStack(spacing: 16) {
                                ForEach(AccountColor.colorOptions, id: \.0) { colorName, colorValue in
                                    Button(action: {
                                        selectedColor = colorName
                                    }) {
                                        Circle()
                                            .fill(colorValue)
                                            .frame(width: 40, height: 40)
                                            .overlay(
                                                Circle()
                                                    .stroke(.white, lineWidth: selectedColor == colorName ? 3 : 0)
                                            )
                                            .shadow(color: colorValue.opacity(0.3), radius: 4, x: 0, y: 2)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // MARK: - Botones de acción
                        VStack(spacing: 16) {
                            // Botón guardar cambios
                            Button(action: {
                                let updatedAccount = Account(
                                    id: account.id,
                                    name: accountName,
                                    type: selectedType,
                                    balance: Double(currentBalance) ?? 0.0,
                                    color: selectedColor
                                )
                                onSave(updatedAccount)
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
                            .disabled(accountName.isEmpty)
                            .opacity(accountName.isEmpty ? 0.6 : 1.0)
                            
                            // Botón eliminar cuenta
                            Button(action: {
                                showingDeleteAlert = true
                            }) {
                                Text("Eliminar Cuenta")
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
            .navigationTitle("Editar Cuenta")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
        }
        .alert("Eliminar Cuenta", isPresented: $showingDeleteAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Eliminar", role: .destructive) {
                onDelete(account)
                dismiss()
            }
        } message: {
            Text("¿Estás seguro de que quieres eliminar '\(account.name)'? Esta acción no se puede deshacer.")
        }
    }
    
    private func getTypeIcon() -> String {
        switch selectedType {
        case AccountType.bank: return "building.columns.fill"
        case AccountType.credit: return "creditcard.fill"
        case AccountType.cash: return "banknote.fill"
        case AccountType.savings: return "piggybank.fill"
        default: return "wallet.pass.fill"
        }
    }
}
