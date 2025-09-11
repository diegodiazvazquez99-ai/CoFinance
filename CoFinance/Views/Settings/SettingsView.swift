import SwiftUI

// MARK: - SETTINGS VIEW
struct SettingsView: View {
    @EnvironmentObject var coreDataManager: CoreDataManager
    @State private var accounts: [AccountEntity] = []
    @State private var showingRecalculateAlert = false
    
    var body: some View {
        NavigationView {
            List {
                // MARK: - Gestión Financiera
                Section {
                    NavigationLink(destination: AccountManagementView()) {
                        HStack {
                            Image(systemName: "creditcard")
                                .foregroundColor(.blue)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Gestión de Cuentas")
                                Text("\(accounts.count) cuenta\(accounts.count == 1 ? "" : "s")")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                } header: {
                    Text("Finanzas")
                }
                
                // MARK: - Configuración de la App
                Section {
                    NavigationLink(destination: NotificationsSettingsView()) {
                        HStack {
                            Image(systemName: "bell")
                                .foregroundColor(.orange)
                            Text("Notificaciones")
                        }
                    }
                    
                    NavigationLink(destination: PrivacySettingsView()) {
                        HStack {
                            Image(systemName: "lock")
                                .foregroundColor(.green)
                            Text("Privacidad y Seguridad")
                        }
                    }
                    
                    NavigationLink(destination: ExportDataView()) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.blue)
                            Text("Exportar Datos")
                        }
                    }
                } header: {
                    Text("Configuración")
                }
                
                // MARK: - Datos y Respaldo
                Section {
                    Button(action: {
                        coreDataManager.createSampleDataIfNeeded()
                        loadAccounts()
                    }) {
                        HStack {
                            Image(systemName: "doc")
                                .foregroundColor(.purple)
                            Text("Crear datos de ejemplo")
                        }
                    }
                    
                    NavigationLink(destination: BackupSettingsView()) {
                        HStack {
                            Image(systemName: "icloud")
                                .foregroundColor(.blue)
                            Text("Respaldo y Sincronización")
                        }
                    }
                } header: {
                    Text("Datos")
                } footer: {
                    Text("Los datos de ejemplo te ayudan a probar la aplicación.")
                }
                
                // MARK: - 🔧 Herramientas de Debugging
                Section {
                    Button(action: {
                        showingRecalculateAlert = true
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(.orange)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Recalcular Balances")
                                Text("Corrige inconsistencias en balances")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    NavigationLink(destination: BalanceDebugView()) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.blue)
                            Text("Inspector de Balances")
                        }
                    }
                } header: {
                    Text("🔧 Herramientas de Desarrollo")
                } footer: {
                    Text("Herramientas para debugging y verificación de datos.")
                }
                
                // MARK: - Información de la App
                Section {
                    HStack {
                        Text("Versión")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Arquitectura")
                        Spacer()
                        Text("Refactorizada + Balance Fix")
                            .foregroundColor(.secondary)
                    }
                    
                    NavigationLink(destination: AboutView()) {
                        HStack {
                            Image(systemName: "info")
                                .foregroundColor(.blue)
                            Text("Acerca de CoFinance")
                        }
                    }
                    
                    NavigationLink(destination: FeedbackView()) {
                        HStack {
                            Image(systemName: "envelope")
                                .foregroundColor(.blue)
                            Text("Enviar Feedback")
                        }
                    }
                } header: {
                    Text("Acerca de la App")
                }
            }
            .navigationTitle("Ajustes")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            loadAccounts()
        }
        .alert("Recalcular Balances", isPresented: $showingRecalculateAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Recalcular", role: .destructive) {
                coreDataManager.recalculateAllBalances()
                loadAccounts()
            }
        } message: {
            Text("Esto recalculará todos los balances basándose en las transacciones existentes. ¿Continuar?")
        }
    }
    
    private func loadAccounts() {
        accounts = coreDataManager.fetchAccounts()
    }
}

// MARK: - BALANCE DEBUG VIEW - SUPER SIMPLIFICADO
struct BalanceDebugView: View {
    @EnvironmentObject var coreDataManager: CoreDataManager
    @State private var accounts: [AccountEntity] = []
    @State private var transactions: [TransactionEntity] = []
    
    var body: some View {
        List {
            Section {
                if accounts.isEmpty {
                    Text("No hay cuentas para analizar")
                        .foregroundColor(.secondary)
                        .italic()
                } else {
                    ForEach(accounts, id: \.id) { account in
                        let accountTransactions = transactions.filter { $0.accountName == account.name }
                        let calculatedBalance = accountTransactions.reduce(0.0) { total, transaction in
                            return total + (transaction.isIncome ? transaction.amount : -transaction.amount)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(account.name ?? "Sin nombre")
                                .font(.headline)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text("Balance guardado:")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("$\(account.balance, specifier: "%.2f")")
                                        .font(.caption)
                                        .foregroundColor(account.balance >= 0 ? .primary : .red)
                                }
                                
                                HStack {
                                    Text("Balance calculado:")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("$\(calculatedBalance, specifier: "%.2f")")
                                        .font(.caption)
                                        .foregroundColor(calculatedBalance >= 0 ? .primary : .red)
                                }
                                
                                HStack {
                                    Text("Diferencia:")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    let difference = account.balance - calculatedBalance
                                    Text("$\(difference, specifier: "%.2f")")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(abs(difference) < 0.01 ? .green : .red)
                                }
                                
                                HStack {
                                    Text("Transacciones:")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("\(accountTransactions.count)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            } header: {
                HStack {
                    Text("Estado de Balances")
                    Spacer()
                    Button("Refrescar") {
                        loadData()
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            } footer: {
                Text("Verde = Correcto, Rojo = Inconsistencia detectada")
            }
            
            Section {
                let totalStoredBalance = accounts.reduce(0.0) { $0 + $1.balance }
                let totalCalculatedBalance = accounts.reduce(0.0) { total, account in
                    let accountTransactions = transactions.filter { $0.accountName == account.name }
                    let calculated = accountTransactions.reduce(0.0) { subTotal, transaction in
                        return subTotal + (transaction.isIncome ? transaction.amount : -transaction.amount)
                    }
                    return total + calculated
                }
                
                VStack(spacing: 12) {
                    HStack {
                        Text("Total guardado:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("$\(totalStoredBalance, specifier: "%.2f")")
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                    
                    HStack {
                        Text("Total calculado:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("$\(totalCalculatedBalance, specifier: "%.2f")")
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                    
                    HStack {
                        Text("Diferencia total:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        let totalDifference = totalStoredBalance - totalCalculatedBalance
                        Text("$\(totalDifference, specifier: "%.2f")")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(abs(totalDifference) < 0.01 ? .green : .red)
                    }
                }
                .padding(.vertical, 8)
            } header: {
                Text("Resumen General")
            }
        }
        .navigationTitle("Inspector de Balances")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            loadData()
        }
        .refreshable {
            loadData()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Recalcular") {
                    coreDataManager.recalculateAllBalances()
                    loadData()
                }
                .foregroundColor(.orange)
            }
        }
    }
    
    private func loadData() {
        accounts = coreDataManager.fetchAccounts()
        transactions = coreDataManager.fetchTransactions()
    }
}

// MARK: - PLACEHOLDER VIEWS SUPER SIMPLES
struct NotificationsSettingsView: View {
    var body: some View {
        List {
            Section {
                Text("Configuración de notificaciones")
                Text("Próximamente...")
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Notificaciones")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct PrivacySettingsView: View {
    var body: some View {
        List {
            Section {
                Text("Configuración de privacidad")
                Text("Próximamente...")
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Privacidad")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct ExportDataView: View {
    var body: some View {
        List {
            Section {
                Text("Exportar datos")
                Text("Próximamente...")
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Exportar Datos")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct BackupSettingsView: View {
    var body: some View {
        List {
            Section {
                Text("Configuración de respaldos")
                Text("Próximamente...")
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Respaldos")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct AboutView: View {
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("CoFinance")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("App de gestión financiera personal")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("Versión 1.0.0 - Balance Fix")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
            }
        }
        .navigationTitle("Acerca de")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct FeedbackView: View {
    var body: some View {
        List {
            Section {
                Text("Enviar feedback")
                Text("Próximamente...")
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Feedback")
        .navigationBarTitleDisplayMode(.large)
    }
}
