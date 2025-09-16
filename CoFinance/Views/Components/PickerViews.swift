import SwiftUI

// MARK: - ACCOUNT PICKER VIEW
struct AccountPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var coreDataManager: CoreDataManager
    @Binding var selectedAccount: String
    @State private var accounts: [AccountEntity] = []
    
    var accountNames: [String] {
        accounts.map { $0.name ?? "" }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if accounts.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "creditcard")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        
                        Text("No hay cuentas")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Crea una cuenta primero en la pestaña de Cuentas")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(accountNames, id: \.self) { accountName in
                            Button(action: {
                                selectedAccount = accountName
                                dismiss()
                            }) {
                                HStack {
                                    // Buscar la cuenta para mostrar el icono
                                    if let account = accounts.first(where: { $0.name == accountName }) {
                                        Circle()
                                            .fill(account.colorValue)
                                            .frame(width: 24, height: 24)
                                            .overlay(
                                                Image(systemName: account.typeIcon)
                                                    .font(.caption)
                                                    .foregroundColor(.white)
                                            )
                                    }
                                    
                                    Text(accountName)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    if selectedAccount == accountName {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .navigationTitle("Seleccionar Cuenta")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Listo") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            print("🚀 AccountPickerView apareció - cargando cuentas...")
            loadAccounts()
        }
    }
    
    private func loadAccounts() {
        accounts = coreDataManager.fetchAccounts()
        print("📝 AccountPickerView cargó \(accounts.count) cuentas: \(accounts.map { $0.name ?? "Sin nombre" })")
        
        // Si hay cuentas y no hay una seleccionada, seleccionar la primera
        if !accounts.isEmpty && selectedAccount.isEmpty {
            selectedAccount = accounts.first?.name ?? ""
            print("✅ Cuenta seleccionada automáticamente: \(selectedAccount)")
        }
    }
}

// MARK: - CATEGORY PICKER VIEW
struct CategoryPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedCategory: String
    let categories: [String]
    let isIncome: Bool
    
    private func getCategoryIcon(for category: String) -> String {
        return TransactionCategory.icon(for: category, isIncome: isIncome)
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(categories, id: \.self) { category in
                    Button(action: {
                        selectedCategory = category
                        dismiss()
                    }) {
                        HStack {
                            Circle()
                                .fill(isIncome ? .green.opacity(0.2) : .red.opacity(0.2))
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Image(systemName: getCategoryIcon(for: category))
                                        .font(.caption)
                                        .foregroundColor(isIncome ? .green : .red)
                                )
                            
                            Text(category)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if selectedCategory == category {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("Seleccionar Categoría")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Listo") {
                        dismiss()
                    }
                }
            }
        }
    }
}
