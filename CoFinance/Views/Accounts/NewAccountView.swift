import SwiftUI

// MARK: - NEW ACCOUNT VIEW
struct NewAccountView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var coreDataManager: CoreDataManager
    let onSave: (Account) -> Void
    
    @State private var accountName = ""
    @State private var selectedType = AccountType.bank
    @State private var initialBalance = ""
    @State private var selectedColor = "blue"
    
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
                        Text(accountName.isEmpty ? "Nueva Cuenta" : accountName)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("$\(initialBalance.isEmpty ? "0.00" : initialBalance)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
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
                                
                                TextField("Ej: Cuenta Banco", text: $accountName)
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
                            
                            // Balance inicial
                            HStack(spacing: 16) {
                                Image(systemName: "dollarsign.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 24)
                                
                                Text("Balance Inicial")
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                TextField("0.00", text: $initialBalance)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .foregroundColor(.secondary)
                                    .numericOnly($initialBalance, includeDecimal: true)
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
                        
                        // MARK: - Botón crear cuenta
                        Button(action: {
                            let _ = coreDataManager.saveAccount(
                                name: accountName,
                                type: selectedType,
                                balance: Double(initialBalance) ?? 0.0,
                                color: selectedColor
                            )
                            onSave(Account(
                                id: UUID(),
                                name: accountName,
                                type: selectedType,
                                balance: Double(initialBalance) ?? 0.0,
                                color: selectedColor
                            ))
                            dismiss()
                        }) {
                            Text("Crear Cuenta")
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
                        .disabled(accountName.isEmpty)
                        .opacity(accountName.isEmpty ? 0.6 : 1.0)
                        
                        Spacer(minLength: 50)
                    }
                }
            }
            .background(.ultraThinMaterial)
            .navigationTitle("Nueva Cuenta")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
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
