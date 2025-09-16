// CoFinance/Views/Accounts/AccountsView.swift - TOOLBAR AVANZADO Y TRANSPARENTE

import SwiftUI
import Combine
import CoreData

struct AccountsView: View {
    @EnvironmentObject var coreDataManager: CoreDataManager
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingNewAccount = false
    @State private var showingAccountManagement = false
    @State private var showingExportOptions = false
    @State private var refreshID = UUID()
    
    @Environment(\.appTheme) private var theme
    @EnvironmentObject var settings: SettingsManager
    
    @FetchRequest(
        entity: AccountEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \AccountEntity.createdAt, ascending: true)]
    ) var accounts: FetchedResults<AccountEntity>
    
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
                    // Balance Total Card
                    balanceTotalCard
                    
                    // Mis Cuentas Section
                    accountsSection
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .background(Color("AppBackground"))
            .refreshable {
                print("🔄 Manual refresh en AccountsView")
                refreshID = UUID()
            }
            // 🚀 TOOLBAR AVANZADO PARA GESTIÓN DE CUENTAS
            .toolbar {
                // LEADING: Acciones secundarias avanzadas
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        // Información de cuentas
                        Section {
                            Label("\(accounts.count) cuentas", systemImage: "creditcard")
                            Label("Balance: \(formatBalance(totalBalance))", systemImage: "dollarsign.circle")
                        }
                        
                        Divider()
                        
                        // Gestión avanzada
                        Section("Gestión") {
                            Button(action: {
                                showingAccountManagement = true
                            }) {
                                Label("Gestionar cuentas", systemImage: "slider.horizontal.3")
                            }
                            
                            Button(action: {
                                coreDataManager.recalculateAllBalances()
                            }) {
                                Label("Recalcular balances", systemImage: "arrow.clockwise")
                            }
                        }
                        
                        Divider()
                        
                        // Exportar y compartir
                        Section("Exportar") {
                            Button(action: {
                                showingExportOptions = true
                            }) {
                                Label("Exportar datos", systemImage: "square.and.arrow.up")
                            }
                            
                            Button(action: {
                                shareAccountsSummary()
                            }) {
                                Label("Compartir resumen", systemImage: "square.and.arrow.up.on.square")
                            }
                        }
                        
                    } label: {
                        ZStack {
                            Image(systemName: "ellipsis.circle.fill")
                                .font(.title3)
                                .foregroundColor(theme.accentColor)
                            
                            // Badge si hay cuentas con balance negativo
                            if hasNegativeAccounts {
                                Circle()
                                    .fill(.red)
                                    .frame(width: 8, height: 8)
                                    .offset(x: 8, y: -8)
                            }
                        }
                    }
                    .accessibilityLabel("Más opciones de cuentas")
                }
                
                // PRINCIPAL: Título Cuentas centrado
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 8) {
                        Image(systemName: "creditcard.fill")
                            .font(.title3)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [theme.accentColor, theme.accentColor.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Text("Cuentas")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                }
                
                // TRAILING: Acciones principales
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    // Balance rápido en iPad
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(settings.formatCurrency(totalBalance))
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(totalBalance >= 0 ? .green : .red)
                            Text("\(accounts.count) cuentas")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
                    }
                    
                    // Agregar cuenta (acción principal)
                    Button(action: {
                        showingNewAccount = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(theme.accentColor)
                            .symbolEffect(.bounce.up, options: .nonRepeating)
                    }
                    .accessibilityLabel("Agregar nueva cuenta")
                }
            }
            // 🎨 TOOLBAR STYLING TRANSPARENTE
            .toolbarBackground(.clear, for: .navigationBar)
            .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
            .toolbarColorScheme(settings.isDarkMode ? .dark : .light, for: .navigationBar)
        }
        .sheet(isPresented: $showingNewAccount) {
            NewAccountView { newAccount in
                print("✅ Nueva cuenta creada: \(newAccount.name)")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    refreshID = UUID()
                }
            }
        }
        .sheet(isPresented: $showingAccountManagement) {
            AccountManagementView()
        }
        .confirmationDialog("Exportar Datos", isPresented: $showingExportOptions) {
            Button("Exportar CSV") {
                exportAccountsToCSV()
            }
            Button("Exportar PDF") {
                exportAccountsToPDF()
            }
            Button("Resumen completo") {
                exportCompleteReport()
            }
            Button("Cancelar", role: .cancel) { }
        } message: {
            Text("Exportar información de \(accounts.count) cuentas")
        }
        .onAppear {
            logAccountsAppearance()
        }
        .onChange(of: accounts.count) { _, newCount in
            print("📊 AccountsView detectó cambio en número de cuentas: \(newCount)")
            refreshID = UUID()
        }
        .onChange(of: totalBalance) { oldBalance, newBalance in
            print("💰 AccountsView detectó cambio en balance total: $\(oldBalance) → $\(newBalance)")
            for account in accounts {
                print("  💳 \(account.name ?? "Sin nombre"): $\(account.balance)")
            }
            refreshID = UUID()
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)) { _ in
            print("🔄 CoreData context saved - forzando refresh de tarjetas")
            refreshID = UUID()
        }
    }
    
    // MARK: - BALANCE TOTAL CARD
    private var balanceTotalCard: some View {
        VStack(spacing: 16) {
            // Header con indicador de estado
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Balance Total")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Text("Actualizado ahora")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                
                Spacer()
                
                // Status indicator
                Circle()
                    .fill(totalBalance >= 0 ? Color.green : Color.red)
                    .frame(width: 8, height: 8)
                    .overlay(Circle().stroke(.white, lineWidth: 1))
            }
            
            // Balance principal
            Text(settings.formatCurrency(totalBalance))
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .foregroundStyle(
                    totalBalance >= 0 ?
                    LinearGradient(colors: [.primary, theme.accentColor], startPoint: .leading, endPoint: .trailing) :
                    LinearGradient(colors: [.red, .orange], startPoint: .leading, endPoint: .trailing)
                )
                .contentTransition(.numericText())
            
            // Mini resumen si hay cuentas
            if !accounts.isEmpty {
                HStack(spacing: 20) {
                    VStack(spacing: 4) {
                        Text("Positivo")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(settings.formatCurrency(positiveBalance))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                    
                    if negativeBalance < 0 {
                        VStack(spacing: 4) {
                            Text("Negativo")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(settings.formatCurrency(negativeBalance))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.red)
                        }
                    }
                    
                    VStack(spacing: 4) {
                        Text("Cuentas")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(accounts.count)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
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
    }
    
    // MARK: - ACCOUNTS SECTION
    private var accountsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Mis Cuentas")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
                
                HStack(spacing: 8) {
                    if hasNegativeAccounts {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                    }
                    
                    Text("\(accounts.count)")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.secondary.opacity(0.2), in: RoundedRectangle(cornerRadius: 6))
                        .foregroundColor(.secondary)
                }
            }
            
            if accounts.isEmpty {
                emptyAccountsView
            } else {
                accountsGrid
            }
        }
    }
    
    // MARK: - EMPTY ACCOUNTS VIEW
    private var emptyAccountsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "creditcard")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
                .symbolEffect(.pulse, options: .repeating)
            
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
            .foregroundColor(theme.accentColor)
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .padding(.vertical, 20)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - ACCOUNTS GRID
    private var accountsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            ForEach(accounts, id: \.id) { accountEntity in
                NavigationLink(destination: AccountDetailView(account: accountEntity.toAccount())) {
                    AccountCardEntityView(accountEntity: accountEntity)
                }
                .buttonStyle(.plain)
            }
        }
        .id(refreshID)
    }
    
    // MARK: - Helper Properties
    private var hasNegativeAccounts: Bool {
        accounts.contains { $0.balance < 0 }
    }
    
    // MARK: - Helper Methods
    private func formatBalance(_ balance: Double) -> String {
        return settings.formatCurrency(balance)
    }
    
    private func exportAccountsToCSV() {
        print("📤 Exportando \(accounts.count) cuentas a CSV...")
        // TODO: Implementar exportación CSV real
        
        // Ejemplo de estructura CSV:
        let csvHeader = "Nombre,Tipo,Balance,Color,Fecha Creación"
        var csvContent = csvHeader + "\n"
        
        for account in accounts {
            let row = "\(account.name ?? ""),\(account.type ?? ""),\(account.balance),\(account.color ?? ""),\(account.createdAt ?? Date())"
            csvContent += row + "\n"
        }
        
        print("📄 CSV generado: \(csvContent.prefix(200))...")
    }
    
    private func exportAccountsToPDF() {
        print("📤 Exportando \(accounts.count) cuentas a PDF...")
        // TODO: Implementar exportación PDF real
    }
    
    private func exportCompleteReport() {
        print("📤 Generando reporte completo de cuentas...")
        // TODO: Implementar reporte completo con gráficos
    }
    
    private func shareAccountsSummary() {
        print("📤 Compartiendo resumen de cuentas...")
        let summary = """
        📊 Resumen de Cuentas - CoFinance
        
        💰 Balance Total: \(settings.formatCurrency(totalBalance))
        📱 Total de Cuentas: \(accounts.count)
        
        ✅ Balances Positivos: \(settings.formatCurrency(positiveBalance))
        ⚠️ Balances Negativos: \(settings.formatCurrency(negativeBalance))
        
        Generado el \(DateFormatter.mediumDate.string(from: Date()))
        """
        
        print("📝 Resumen generado: \(summary)")
        
        // TODO: Implementar UIActivityViewController para compartir
    }
    
    private func logAccountsAppearance() {
        print("🔄 AccountsView apareció con \(accounts.count) cuentas:")
        for account in accounts {
            print("  💳 \(account.name ?? "Sin nombre"): \(settings.formatCurrency(account.balance))")
        }
        print("  💰 Balance total: \(settings.formatCurrency(totalBalance))")
        print("  💱 Divisa actual: \(settings.preferredCurrency) (\(settings.currencySymbol))")
    }
}

// MARK: - ACCOUNT CARD ENTITY VIEW (Trabaja directamente con AccountEntity)
struct AccountCardEntityView: View {
    @ObservedObject var accountEntity: AccountEntity
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.appTheme) private var theme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [accountEntity.colorValue, accountEntity.colorValue.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 36, height: 36)
                    .overlay(
                        Image(systemName: accountEntity.typeIcon)
                            .font(.title3)
                            .foregroundColor(.white)
                    )
                    .shadow(color: accountEntity.colorValue.opacity(0.3), radius: 6, x: 0, y: 3)
                Spacer()
                
                Text(accountEntity.type ?? "Tipo")
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(accountEntity.colorValue.opacity(0.2), in: RoundedRectangle(cornerRadius: 8))
                    .foregroundColor(accountEntity.colorValue)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(accountEntity.name ?? "Sin nombre")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(settings.formatCurrency(accountEntity.balance))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(accountEntity.balance >= 0 ? .primary : .red)
                    .contentTransition(.numericText())
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.ultraThinMaterial, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        .onReceive(accountEntity.objectWillChange) { _ in
            print("🔄 AccountCardEntityView detectó cambio en: \(accountEntity.name ?? "Sin nombre") - \(settings.formatCurrency(accountEntity.balance))")
        }
    }
}

// MARK: - PREVIEW
#Preview {
    AccountsView()
        .environmentObject(CoreDataManager.shared)
        .environmentObject(SettingsManager.shared)
        .appTheme(AppTheme())
}
