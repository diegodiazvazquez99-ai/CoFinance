import SwiftUI

// MARK: - ACCOUNTS VIEW
struct AccountsView: View {
    @EnvironmentObject var coreDataManager: CoreDataManager
    @State private var showingNewAccount = false
    @State private var showingEditAccount = false
    @State private var selectedAccountEntity: AccountEntity?
    @State private var accounts: [AccountEntity] = []
    
    var totalBalance: Double {
        accounts.reduce(0) { $0 + $1.balance }
    }
    
    var positiveBalance: Double {
        accounts.filter { $0.balance > 0 }.reduce(0) { $0 + $1.balance }
    }
    
    var negativeBalance: Double {
        accounts.filter { $0.balance < 0 }.reduce(0) { $0 + $1.balance }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - Balance Total Card
                    VStack(spacing: 16) {
                        Text("Balance Total")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Text("$\(totalBalance, specifier: "%.2f")")
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .contentTransition(.numericText())
                        
                        // Mini resumen si hay cuentas
                        if !accounts.isEmpty {
                            HStack(spacing: 20) {
                                VStack(spacing: 4) {
                                    Text("Positivo")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("$\(positiveBalance, specifier: "%.2f")")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.green)
                                }
                                
                                if negativeBalance < 0 {
                                    VStack(spacing: 4) {
                                        Text("Negativo")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text("$\(negativeBalance, specifier: "%.2f")")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 28)
                    .padding(.horizontal, 24)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.ultraThinMaterial, lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    
                    // MARK: - Mis Cuentas Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Mis Cuentas")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Spacer()
                            Button(action: {
                                showingNewAccount = true
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "plus")
                                        .font(.caption)
                                    Text("Agregar")
                                        .font(.subheadline)
                                }
                                .foregroundColor(.blue)
                            }
                        }
                        
                        if accounts.isEmpty {
                            // Estado vacío
                            VStack(spacing: 16) {
                                Image(systemName: "creditcard")
                                    .font(.system(size: 40))
                                    .foregroundColor(.secondary)
                                
                                Text("No hay cuentas")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                Text("Agrega tu primera cuenta para comenzar a gestionar tus finanzas")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                
                                Button("Crear primera cuenta") {
                                    showingNewAccount = true
                                }
                                .font(.headline)
                                .foregroundColor(.blue)
                                .padding(.top, 8)
                            }
                            .frame(maxWidth: .infinity, minHeight: 200)
                            .padding(.vertical, 20)
                            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
                        } else {
                            // Grid de cuentas
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 16) {
                                ForEach(accounts, id: \.id) { accountEntity in
                                    AccountCardView(account: accountEntity.toAccount()) {
                                        selectedAccountEntity = accountEntity
                                        showingEditAccount = true
                                    }
                                }
                            }
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .navigationTitle("Cuentas")
            .navigationBarTitleDisplayMode(.large)
            .background(.ultraThinMaterial)
            .refreshable {
                loadAccounts()
            }
        }
        .onAppear {
            loadAccounts()
        }
    }
    
    private func loadAccounts() {
        accounts = coreDataManager.fetchAccounts()
        print("🔄 AccountsView recargó \(accounts.count) cuentas:")
        for account in accounts {
            print("  💳 \(account.name ?? "Sin nombre"): $\(account.balance)")
        }
    }
}
