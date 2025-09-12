import SwiftUI

// MARK: - SETTINGS VIEW (FIXED)
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
                        SettingsRow(
                            icon: "creditcard",
                            iconColor: .blue,
                            title: "Gestión de Cuentas",
                            subtitle: "\(accounts.count) cuenta\(accounts.count == 1 ? "" : "s")"
                        )
                    }
                } header: {
                    Text("Finanzas")
                }
                
                // MARK: - Configuración de la App
                Section {
                    NavigationLink(destination: NotificationsSettingsView()) {
                        SettingsRow(
                            icon: "bell",
                            iconColor: .orange,
                            title: "Notificaciones"
                        )
                    }
                    
                    NavigationLink(destination: PrivacySettingsView()) {
                        SettingsRow(
                            icon: "lock",
                            iconColor: .green,
                            title: "Privacidad y Seguridad"
                        )
                    }
                    
                    NavigationLink(destination: ExportDataView()) {
                        SettingsRow(
                            icon: "square.and.arrow.up",
                            iconColor: .blue,
                            title: "Exportar Datos"
                        )
                    }
                } header: {
                    Text("Configuración")
                }
                
                // MARK: - Datos y Respaldo
                Section {
                    Button(action: {
                        withAnimation {
                            coreDataManager.createSampleDataIfNeeded()
                            loadAccounts()
                        }
                    }) {
                        SettingsRow(
                            icon: "doc.fill",
                            iconColor: .purple,
                            title: "Crear datos de ejemplo"
                        )
                    }
                    .buttonStyle(.plain)
                    
                    NavigationLink(destination: BackupSettingsView()) {
                        SettingsRow(
                            icon: "icloud",
                            iconColor: .blue,
                            title: "Respaldo y Sincronización"
                        )
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
                        SettingsRow(
                            icon: "arrow.clockwise",
                            iconColor: .orange,
                            title: "Recalcular Balances",
                            subtitle: "Corrige inconsistencias en balances"
                        )
                    }
                    .buttonStyle(.plain)
                    
                    NavigationLink(destination: BalanceDebugView()) {
                        SettingsRow(
                            icon: "magnifyingglass",
                            iconColor: .blue,
                            title: "Inspector de Balances"
                        )
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
                            .font(.caption)
                    }
                    
                    NavigationLink(destination: AboutView()) {
                        SettingsRow(
                            icon: "info.circle",
                            iconColor: .blue,
                            title: "Acerca de CoFinance"
                        )
                    }
                    
                    NavigationLink(destination: FeedbackView()) {
                        SettingsRow(
                            icon: "envelope",
                            iconColor: .blue,
                            title: "Enviar Feedback"
                        )
                    }
                } header: {
                    Text("Acerca de la App")
                }
            }
            .navigationTitle("Ajustes")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadAccounts()
            }
            .alert("Recalcular Balances", isPresented: $showingRecalculateAlert) {
                Button("Cancelar", role: .cancel) { }
                Button("Recalcular", role: .destructive) {
                    withAnimation {
                        coreDataManager.recalculateAllBalances()
                        loadAccounts()
                    }
                }
            } message: {
                Text("Esto recalculará todos los balances basándose en las transacciones existentes. ¿Continuar?")
            }
        }
    }
    
    private func loadAccounts() {
        accounts = coreDataManager.fetchAccounts()
    }
}

// MARK: - SETTINGS ROW COMPONENT (Para evitar repetición y problemas)
struct SettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String?
    
    init(icon: String, iconColor: Color, title: String, subtitle: String? = nil) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.subtitle = subtitle
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // 🔥 Crear imagen de manera más segura
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .font(.system(size: 16, weight: .medium))
                .frame(width: 20, height: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .frame(minHeight: 44) // Asegurar altura mínima
    }
}

// MARK: - BALANCE DEBUG VIEW (MEJORADO)
struct BalanceDebugView: View {
    @EnvironmentObject var coreDataManager: CoreDataManager
    @State private var accounts: [AccountEntity] = []
    @State private var transactions: [TransactionEntity] = []
    @State private var isLoading = false
    
    var body: some View {
        Group {
            if isLoading {
                VStack {
                    ProgressView("Cargando datos...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            } else {
                List {
                    Section {
                        if accounts.isEmpty {
                            Text("No hay cuentas para analizar")
                                .foregroundColor(.secondary)
                                .italic()
                        } else {
                            ForEach(accounts, id: \.id) { account in
                                BalanceDebugRow(account: account, transactions: transactions)
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
                        BalanceSummaryView(accounts: accounts, transactions: transactions)
                    } header: {
                        Text("Resumen General")
                    }
                }
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
                    withAnimation {
                        coreDataManager.recalculateAllBalances()
                        loadData()
                    }
                }
                .foregroundColor(.orange)
            }
        }
    }
    
    private func loadData() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            accounts = coreDataManager.fetchAccounts()
            transactions = coreDataManager.fetchTransactions()
            isLoading = false
        }
    }
}

// MARK: - BALANCE DEBUG ROW
struct BalanceDebugRow: View {
    let account: AccountEntity
    let transactions: [TransactionEntity]
    
    private var accountTransactions: [TransactionEntity] {
        transactions.filter { $0.accountName == account.name }
    }
    
    private var calculatedBalance: Double {
        accountTransactions.reduce(0.0) { total, transaction in
            return total + (transaction.isIncome ? transaction.amount : -transaction.amount)
        }
    }
    
    private var difference: Double {
        account.balance - calculatedBalance
    }
    
    private var isCorrect: Bool {
        abs(difference) < 0.01
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(account.name ?? "Sin nombre")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 4) {
                DebugBalanceRow(
                    label: "Balance guardado:",
                    value: account.balance,
                    color: account.balance >= 0 ? .primary : .red
                )
                
                DebugBalanceRow(
                    label: "Balance calculado:",
                    value: calculatedBalance,
                    color: calculatedBalance >= 0 ? .primary : .red
                )
                
                DebugBalanceRow(
                    label: "Diferencia:",
                    value: difference,
                    color: isCorrect ? .green : .red,
                    isBold: true
                )
                
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

// MARK: - DEBUG BALANCE ROW HELPER
struct DebugBalanceRow: View {
    let label: String
    let value: Double
    let color: Color
    let isBold: Bool
    
    init(label: String, value: Double, color: Color, isBold: Bool = false) {
        self.label = label
        self.value = value
        self.color = color
        self.isBold = isBold
    }
    
    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text("$\(value, specifier: "%.2f")")
                .font(.caption)
                .fontWeight(isBold ? .semibold : .regular)
                .foregroundColor(color)
        }
    }
}

// MARK: - BALANCE SUMMARY VIEW
struct BalanceSummaryView: View {
    let accounts: [AccountEntity]
    let transactions: [TransactionEntity]
    
    private var totalStoredBalance: Double {
        accounts.reduce(0.0) { $0 + $1.balance }
    }
    
    private var totalCalculatedBalance: Double {
        accounts.reduce(0.0) { total, account in
            let accountTransactions = transactions.filter { $0.accountName == account.name }
            let calculated = accountTransactions.reduce(0.0) { subTotal, transaction in
                return subTotal + (transaction.isIncome ? transaction.amount : -transaction.amount)
            }
            return total + calculated
        }
    }
    
    private var totalDifference: Double {
        totalStoredBalance - totalCalculatedBalance
    }
    
    private var isCorrect: Bool {
        abs(totalDifference) < 0.01
    }
    
    var body: some View {
        VStack(spacing: 12) {
            DebugBalanceRow(
                label: "Total guardado:",
                value: totalStoredBalance,
                color: .primary,
                isBold: true
            )
            
            DebugBalanceRow(
                label: "Total calculado:",
                value: totalCalculatedBalance,
                color: .primary,
                isBold: true
            )
            
            DebugBalanceRow(
                label: "Diferencia total:",
                value: totalDifference,
                color: isCorrect ? .green : .red,
                isBold: true
            )
        }
        .padding(.vertical, 8)
    }
}

// MARK: - PLACEHOLDER VIEWS MEJORADAS
struct NotificationsSettingsView: View {
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Configuración de notificaciones")
                        .font(.headline)
                    Text("Esta funcionalidad estará disponible próximamente. Podrás configurar recordatorios para:")
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Label("Recordatorios de transacciones", systemImage: "bell")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Label("Alertas de presupuesto", systemImage: "chart.bar")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Label("Resúmenes mensuales", systemImage: "calendar")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.leading, 16)
                }
                .padding(.vertical, 8)
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
                VStack(alignment: .leading, spacing: 12) {
                    Text("Configuración de privacidad")
                        .font(.headline)
                    Text("Tu privacidad es importante. Próximamente podrás configurar:")
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Label("Bloqueo con Face ID / Touch ID", systemImage: "faceid")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Label("Cifrado de datos", systemImage: "lock.shield")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Label("Configuración de respaldos", systemImage: "icloud.and.arrow.up")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.leading, 16)
                }
                .padding(.vertical, 8)
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
                VStack(alignment: .leading, spacing: 12) {
                    Text("Exportar datos")
                        .font(.headline)
                    Text("Próximamente podrás exportar tus datos financieros en diferentes formatos:")
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Label("Exportar a CSV", systemImage: "doc.text")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Label("Exportar a PDF", systemImage: "doc.richtext")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Label("Compartir reportes", systemImage: "square.and.arrow.up")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.leading, 16)
                }
                .padding(.vertical, 8)
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
                VStack(alignment: .leading, spacing: 12) {
                    Text("Configuración de respaldos")
                        .font(.headline)
                    Text("Mantén tus datos seguros con respaldos automáticos:")
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Label("Respaldo automático a iCloud", systemImage: "icloud")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Label("Restaurar desde respaldo", systemImage: "arrow.clockwise.icloud")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Label("Sincronización entre dispositivos", systemImage: "iphone.and.ipad")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.leading, 16)
                }
                .padding(.vertical, 8)
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
                VStack(alignment: .center, spacing: 16) {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    VStack(spacing: 8) {
                        Text("CoFinance")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("App de gestión financiera personal")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("Versión 1.0.0 - Balance Fix")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            }
            
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Desarrollado con:")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Label("SwiftUI", systemImage: "swift")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Label("CoreData", systemImage: "cylinder.split.1x2")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Label("Xcode 16.0 Beta RC", systemImage: "hammer")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.leading, 16)
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
                VStack(alignment: .leading, spacing: 12) {
                    Text("Enviar feedback")
                        .font(.headline)
                    Text("Tu opinión es importante para mejorar CoFinance:")
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Label("Reportar bugs", systemImage: "ladybug")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Label("Sugerir funcionalidades", systemImage: "lightbulb")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Label("Valorar la app", systemImage: "star")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.leading, 16)
                }
                .padding(.vertical, 8)
            }
        }
        .navigationTitle("Feedback")
        .navigationBarTitleDisplayMode(.large)
    }
}
