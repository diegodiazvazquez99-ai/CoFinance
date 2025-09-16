import SwiftUI

// MARK: - ACCOUNT MANAGEMENT VIEW
struct AccountManagementView: View {
    @EnvironmentObject var coreDataManager: CoreDataManager
    @State private var accounts: [AccountEntity] = []
    @State private var showingNewAccount = false
    @State private var showingEditAccount = false
    @State private var selectedAccountEntity: AccountEntity?
    
    var totalBalance: Double {
        accounts.reduce(0) { $0 + $1.balance }
    }
    
    var body: some View {
        List {
            // MARK: - Resumen
            Section {
                VStack(spacing: 12) {
                    HStack {
                        Text("Balance Total")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("$\(totalBalance, specifier: "%.2f")")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(totalBalance >= 0 ? .primary : .red)
                    }
                    
                    HStack {
                        Text("Total de cuentas")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(accounts.count)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                }
                .padding(.vertical, 8)
            } header: {
                Text("Resumen")
            }
            
            // MARK: - Lista de Cuentas
            Section {
                if accounts.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "creditcard")
                            .font(.title)
                            .foregroundColor(.secondary)
                        
                        Text("No hay cuentas")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Crea tu primera cuenta para comenzar")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                } else {
                    ForEach(accounts, id: \.id) { account in
                        AccountManagementRow(account: account) {
                            selectedAccountEntity = account
                            showingEditAccount = true
                        }
                    }
                }
                
                // Botón agregar nueva cuenta
                Button(action: {
                    showingNewAccount = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                        Text("Agregar nueva cuenta")
                            .foregroundColor(.blue)
                    }
                }
            } header: {
                Text("Cuentas (\(accounts.count))")
            } footer: {
                Text("Toca una cuenta para editarla o eliminarla. Los cambios se reflejarán inmediatamente en toda la aplicación.")
            }
        }
        // Oculta el fondo por defecto de la List para permitir un color personalizado
        .scrollContentBackground(.hidden)
        // Aplica tu color de fondo personalizado
        .background(Color("AppBackground"))
        .navigationTitle("Gestión de Cuentas")
        .navigationBarTitleDisplayMode(.large)
        .refreshable {
            loadAccounts()
        }
        .onAppear {
            loadAccounts()
        }
        .sheet(isPresented: $showingNewAccount) {
            NewAccountView { newAccount in
                loadAccounts()
            }
        }
        .sheet(isPresented: $showingEditAccount) {
            if let accountEntity = selectedAccountEntity {
                EditAccountView(
                    account: accountEntity.toAccount(),
                    onSave: { updatedAccount in
                        coreDataManager.updateAccount(
                            accountEntity,
                            name: updatedAccount.name,
                            type: updatedAccount.type,
                            balance: updatedAccount.balance,
                            color: updatedAccount.color
                        )
                        loadAccounts()
                    },
                    onDelete: { accountToDelete in
                        coreDataManager.deleteAccount(accountEntity)
                        loadAccounts()
                    }
                )
            }
        }
    }
    
    private func loadAccounts() {
        accounts = coreDataManager.fetchAccounts()
    }
}

// MARK: - ACCOUNT MANAGEMENT ROW
struct AccountManagementRow: View {
    let account: AccountEntity
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Circle()
                    .fill(account.colorValue)
                    .frame(width: 36, height: 36)
                    .overlay(
                        Image(systemName: account.typeIcon)
                            .font(.caption)
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(account.name ?? "Sin nombre")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack {
                        Text(account.type ?? "Sin tipo")
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(account.colorValue.opacity(0.2), in: RoundedRectangle(cornerRadius: 4))
                            .foregroundColor(account.colorValue)
                        
                        Spacer()
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("$\(account.balance, specifier: "%.2f")")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(account.balance >= 0 ? .primary : .red)
                    
                    Text("Tocar para editar")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
        .buttonStyle(.plain)
    }
}
