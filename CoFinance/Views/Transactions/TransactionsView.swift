// CoFinance/Views/Transactions/TransactionsView.swift - TOOLBAR CON ANÁLISIS Y TRANSPARENTE

import SwiftUI
import Combine
import CoreData

struct TransactionsView: View {
    @EnvironmentObject var coreDataManager: CoreDataManager
    @EnvironmentObject var settings: SettingsManager
    @State private var searchText = ""
    @State private var selectedFilter = "Todas"
    @State private var selectedAccount = "Todas"
    @State private var showingNewTransaction = false
    @State private var showingEditTransaction = false
    @State private var showingAnalytics = false
    @State private var showingExportSheet = false
    @State private var showingFilterSheet = false
    @State private var selectedTransactionEntity: TransactionEntity?
    @State private var scrollPosition = ScrollPosition(edge: .top)
    @State private var showAccountPickerDialog = false
    @State private var showFilterDialog = false
    
    @Environment(\.appTheme) private var theme
    
    @FetchRequest(
        entity: TransactionEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \TransactionEntity.date, ascending: false)]
    ) var transactions: FetchedResults<TransactionEntity>
    
    @FetchRequest(
        entity: AccountEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \AccountEntity.createdAt, ascending: true)]
    ) var accounts: FetchedResults<AccountEntity>
    
    let filterOptions = ["Todas", "Ingresos", "Gastos"]
    
    var accountOptions: [String] {
        var options = ["Todas"]
        options.append(contentsOf: accounts.map { $0.name ?? "" })
        return options
    }
    
    var filteredTransactions: [TransactionEntity] {
        var filtered = Array(transactions)
        
        if !searchText.isEmpty {
            filtered = filtered.filter { transaction in
                (transaction.name?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (transaction.category?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (transaction.accountName?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        switch selectedFilter {
        case "Ingresos":
            filtered = filtered.filter { $0.isIncome }
        case "Gastos":
            filtered = filtered.filter { !$0.isIncome }
        default:
            break
        }
        
        if selectedAccount != "Todas" {
            filtered = filtered.filter { $0.accountName == selectedAccount }
        }
        
        return filtered
    }
    
    // MARK: - Computed Properties para Analytics
    var totalIncome: Double {
        filteredTransactions.filter { $0.isIncome }.reduce(0) { $0 + $1.amount }
    }
    
    var totalExpenses: Double {
        filteredTransactions.filter { !$0.isIncome }.reduce(0) { $0 + $1.amount }
    }
    
    var netBalance: Double {
        totalIncome - totalExpenses
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                compactHeader
                Divider()
                fullScreenTransactionsList
            }
            .navigationBarTitleDisplayMode(.inline)
            // 🚀 TOOLBAR AVANZADO CON ANÁLISIS Y EXPORTACIÓN
            .toolbar {
                // LEADING: Análisis y filtros avanzados
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        // Información de transacciones
                        Section {
                            Label("\(filteredTransactions.count) transacciones", systemImage: "list.bullet.rectangle")
                            Label("Balance neto: \(settings.formatCurrency(netBalance))", systemImage: "equal.circle")
                        }
                        
                        Divider()
                        
                        // Analytics
                        Section("Análisis") {
                            Button(action: {
                                showingAnalytics = true
                            }) {
                                Label("Ver análisis completo", systemImage: "chart.line.uptrend.xyaxis")
                            }
                            
                            Button(action: {
                                showingFilterSheet = true
                            }) {
                                Label("Filtros avanzados", systemImage: "line.3.horizontal.decrease.circle")
                            }
                        }
                        
                        Divider()
                        
                        // Exportar
                        Section("Exportar") {
                            Button(action: {
                                showingExportSheet = true
                            }) {
                                Label("Exportar datos", systemImage: "square.and.arrow.up")
                            }
                            
                            Button(action: {
                                shareQuickSummary()
                            }) {
                                Label("Compartir resumen", systemImage: "square.and.arrow.up.on.square")
                            }
                        }
                        
                        // Limpiar filtros si hay alguno activo
                        if hasActiveFilters {
                            Divider()
                            Button(action: clearFilters) {
                                Label("Limpiar filtros", systemImage: "xmark.circle")
                            }
                        }
                        
                    } label: {
                        ZStack {
                            Image(systemName: "chart.bar.xaxis")
                                .font(.title3)
                                .foregroundColor(.primary)
                            
                            // Badge para filtros activos
                            if hasActiveFilters {
                                Circle()
                                    .fill(.orange)
                                    .frame(width: 8, height: 8)
                                    .offset(x: 8, y: -8)
                            }
                        }
                    }
                    .accessibilityLabel("Análisis y opciones")
                }
                
                // PRINCIPAL: Título Transacciones centrado
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 8) {
                        Text("Transacciones")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                }
                
                // TRAILING: Acciones principales
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    // Resumen rápido en iPad
                    if UIDevice.current.userInterfaceIdiom == .pad && !filteredTransactions.isEmpty {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(settings.formatCurrency(netBalance))
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(netBalance >= 0 ? .green : .red)
                            Text("\(filteredTransactions.count) transacc.")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
                    }
                    
                    // Nueva transacción (acción principal)
                    Button(action: {
                        showingNewTransaction = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title3)
                            .foregroundColor(.primary)
                            .symbolEffect(.bounce.up, options: .nonRepeating)
                    }
                    .accessibilityLabel("Agregar nueva transacción")
                }
            }
            // 🎨 TOOLBAR STYLING TRANSPARENTE
            .toolbarBackground(.clear, for: .navigationBar)
            .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
            .toolbarColorScheme(settings.isDarkMode ? .dark : .light, for: .navigationBar)
        }
        .onAppear {
            logAppearance()
        }
        .onChange(of: transactions.count) { _, newCount in
            print("📊 TransactionsView detectó cambio en número de transacciones: \(newCount)")
        }
        .sheet(isPresented: $showingNewTransaction) {
            NewTransactionView { newTransaction in
                print("✅ Nueva transacción creada: \(newTransaction.name)")
            }
        }
        .sheet(isPresented: $showingEditTransaction) {
            if let transactionEntity = selectedTransactionEntity {
                EditTransactionView(
                    transaction: transactionEntity.toTransaction(),
                    onSave: { updatedTransaction in
                        coreDataManager.updateTransaction(
                            transactionEntity,
                            name: updatedTransaction.name,
                            amount: updatedTransaction.amount,
                            isIncome: updatedTransaction.isIncome,
                            accountName: updatedTransaction.accountName,
                            category: updatedTransaction.category,
                            date: updatedTransaction.date,
                            notes: updatedTransaction.notes
                        )
                        print("✅ Transacción actualizada: \(updatedTransaction.name)")
                    },
                    onDelete: { transactionToDelete in
                        coreDataManager.deleteTransaction(transactionEntity)
                        print("🗑️ Transacción eliminada: \(transactionToDelete.name)")
                    }
                )
            }
        }
        // 📊 Analytics Sheet
        .sheet(isPresented: $showingAnalytics) {
            TransactionAnalyticsView(
                transactions: filteredTransactions,
                totalIncome: totalIncome,
                totalExpenses: totalExpenses,
                netBalance: netBalance
            )
        }
        // 📤 Export Options
        .confirmationDialog("Exportar Transacciones", isPresented: $showingExportSheet) {
            Button("Exportar CSV") {
                exportTransactionsToCSV()
            }
            Button("Exportar PDF") {
                exportTransactionsToPDF()
            }
            Button("Reporte completo") {
                exportCompleteReport()
            }
            Button("Cancelar", role: .cancel) { }
        } message: {
            Text("Exportar \(filteredTransactions.count) transacciones")
        }
        // 🔍 Advanced Filters Sheet
        .sheet(isPresented: $showingFilterSheet) {
            AdvancedFiltersView(
                searchText: $searchText,
                selectedFilter: $selectedFilter,
                selectedAccount: $selectedAccount,
                accounts: Array(accounts)
            )
        }
        // Confirmación dialogs existentes...
        .confirmationDialog("Filtrar por tipo", isPresented: $showFilterDialog, titleVisibility: .visible) {
            ForEach(filterOptions, id: \.self) { filter in
                Button(filter) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedFilter = filter
                    }
                }
            }
            Button("Cancelar", role: .cancel) { }
        }
        .confirmationDialog("Filtrar por cuenta", isPresented: $showAccountPickerDialog, titleVisibility: .visible) {
            ForEach(accountOptions, id: \.self) { account in
                Button(account) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedAccount = account
                    }
                }
            }
            Button("Cancelar", role: .cancel) { }
        }
    }
    
    // MARK: - HEADER COMPACTO
    private var compactHeader: some View {
        VStack(spacing: 16) {
            // Información rápida en una línea
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(filteredTransactions.count) transacciones")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    if hasActiveFilters {
                        Text("Filtrado")
                            .font(.caption)
                            .foregroundColor(theme.accentColor)
                    } else {
                        Text("Mostrando todas")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Balance neto rápido
                VStack(alignment: .trailing, spacing: 2) {
                    Text(settings.formatCurrency(netBalance))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(netBalance >= 0 ? .green : .red)
                    Text("Balance neto")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                // Indicador de estado
                Circle()
                    .fill(hasActiveFilters ? theme.accentColor : Color.green)
                    .frame(width: 8, height: 8)
                    .overlay(Circle().stroke(.white, lineWidth: 1))
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            
            // Barra de búsqueda
            modernSearchBar
            
            // Filtros horizontales
            modernFiltersSection
        }
        .padding(.bottom, 16)
        .background(Color("AppBackground"))
    }
    
    // MARK: - BARRA DE BÚSQUEDA
    private var modernSearchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
                .font(.system(size: 16, weight: .medium))
            
            TextField("Buscar transacciones...", text: $searchText)
                .textFieldStyle(.plain)
                .font(.body)
            
            if !searchText.isEmpty {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        searchText = ""
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.system(size: 16))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.thinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.ultraThinMaterial, lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
    }
    
    // MARK: - FILTROS COMPACTOS
    private var modernFiltersSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // Filtro por tipo
                FilterButton(
                    title: selectedFilter,
                    icon: getFilterIcon(),
                    isSelected: selectedFilter != "Todas",
                    accentColor: theme.accentColor
                ) {
                    showFilterDialog = true
                }
                
                // Filtro por cuenta
                FilterButton(
                    title: selectedAccount == "Todas" ? "Todas las cuentas" : selectedAccount,
                    icon: "creditcard",
                    isSelected: selectedAccount != "Todas",
                    accentColor: theme.accentColor
                ) {
                    showAccountPickerDialog = true
                }
                
                // Botón limpiar filtros
                if hasActiveFilters {
                    FilterButton(
                        title: "Limpiar",
                        icon: "xmark.circle.fill",
                        isSelected: false,
                        accentColor: Color.red,
                        isDestructive: true
                    ) {
                        clearFilters()
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - LISTA COMPLETA DE TRANSACCIONES
    private var fullScreenTransactionsList: some View {
        Group {
            if filteredTransactions.isEmpty {
                emptyStateView
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(groupedTransactions, id: \.key) { group in
                            // Header de sección con mes/año
                            sectionHeader(for: group.key, count: group.value.count)
                            
                            // Transacciones del mes
                            ForEach(group.value, id: \.id) { transaction in
                                TransactionCardView(transaction: transaction.toTransaction())
                                    .onTapGesture {
                                        selectedTransactionEntity = transaction
                                        showingEditTransaction = true
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 4)
                            }
                        }
                        
                        // Espacio adicional al final
                        Spacer(minLength: 100)
                    }
                }
                .scrollPosition($scrollPosition, anchor: .top)
                .background(Color("AppBackground"))
                .refreshable {
                    await performRefresh()
                }
            }
        }
    }
    
    // MARK: - HEADER DE SECCIÓN MINIMALISTA
    private func sectionHeader(for monthYear: String, count: Int) -> some View {
        HStack {
            Text(monthYear)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Spacer()
            
            // Totales del mes
            VStack(alignment: .trailing, spacing: 2) {
                let monthIncome = groupTransactionsByMonth(monthYear: monthYear).filter { $0.isIncome }.reduce(0) { $0 + $1.amount }
                let monthExpenses = groupTransactionsByMonth(monthYear: monthYear).filter { !$0.isIncome }.reduce(0) { $0 + $1.amount }
                let monthNet = monthIncome - monthExpenses
                
                Text(settings.formatCurrency(monthNet))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(monthNet >= 0 ? .green : .red)
                
                Text("\(count)")
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.secondary.opacity(0.15), in: RoundedRectangle(cornerRadius: 4))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(Color("AppBackground"))
    }
    
    // MARK: - EMPTY STATE VIEW
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: searchText.isEmpty ? "tray" : "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
                .symbolEffect(.pulse.wholeSymbol, options: .repeating)
            
            Text("No hay transacciones")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Text(searchText.isEmpty ?
                 "Agrega tu primera transacción" :
                 "No se encontraron resultados para '\(searchText)'")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if searchText.isEmpty {
                Button("Crear transacción") {
                    showingNewTransaction = true
                }
                .font(.headline)
                .foregroundColor(theme.accentColor)
                .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("AppBackground"))
    }
    
    // MARK: - Helper Properties y Methods
    private var groupedTransactions: [(key: String, value: [TransactionEntity])] {
        let grouped = Dictionary(grouping: filteredTransactions) { transaction in
            (transaction.date ?? Date()).monthYearCapitalized
        }
        return grouped.sorted { first, second in
            DateFormatter.monthYear.date(from: first.key) ?? Date() >
            DateFormatter.monthYear.date(from: second.key) ?? Date()
        }
    }
    
    private var hasActiveFilters: Bool {
        selectedFilter != "Todas" || selectedAccount != "Todas" || !searchText.isEmpty
    }
    
    private func getFilterIcon() -> String {
        switch selectedFilter {
        case "Ingresos": return "arrow.down.circle"
        case "Gastos": return "arrow.up.circle"
        default: return "line.3.horizontal.decrease.circle"
        }
    }
    
    private func groupTransactionsByMonth(monthYear: String) -> [TransactionEntity] {
        return filteredTransactions.filter { transaction in
            (transaction.date ?? Date()).monthYearCapitalized == monthYear
        }
    }
    
    private func clearFilters() {
        withAnimation(.easeInOut(duration: 0.3)) {
            selectedFilter = "Todas"
            selectedAccount = "Todas"
            searchText = ""
        }
    }
    
    private func performRefresh() async {
        print("🔄 Manual refresh en TransactionsView")
        try? await Task.sleep(nanoseconds: 500_000_000)
    }
    
    // MARK: - Export Methods
    private func exportTransactionsToCSV() {
        print("📤 Exportando \(filteredTransactions.count) transacciones a CSV...")
        
        // Estructura CSV
        let csvHeader = "Fecha,Nombre,Monto,Tipo,Cuenta,Categoría,Notas"
        var csvContent = csvHeader + "\n"
        
        for transaction in filteredTransactions {
            let dateStr = DateFormatter.mediumDate.string(from: transaction.date ?? Date())
            let type = transaction.isIncome ? "Ingreso" : "Gasto"
            let amount = transaction.amount
            let row = "\(dateStr),\(transaction.name ?? ""),\(amount),\(type),\(transaction.accountName ?? ""),\(transaction.category ?? ""),\(transaction.notes ?? "")"
            csvContent += row + "\n"
        }
        
        print("📄 CSV generado con \(filteredTransactions.count) transacciones")
    }
    
    private func exportTransactionsToPDF() {
        print("📤 Exportando transacciones a PDF...")
        // TODO: Implementar exportación PDF
    }
    
    private func exportCompleteReport() {
        print("📤 Generando reporte completo...")
        // TODO: Implementar reporte completo con gráficos
    }
    
    private func shareQuickSummary() {
        let summary = """
        💰 Resumen de Transacciones - CoFinance
        
        📊 Total de Transacciones: \(filteredTransactions.count)
        💚 Ingresos: \(settings.formatCurrency(totalIncome))
        ❤️ Gastos: \(settings.formatCurrency(totalExpenses))
        💎 Balance Neto: \(settings.formatCurrency(netBalance))
        
        Período: \(hasActiveFilters ? "Filtrado" : "Completo")
        Generado: \(DateFormatter.mediumDate.string(from: Date()))
        """
        
        print("📝 Resumen compartido: \(summary)")
        // TODO: Implementar UIActivityViewController
    }
    
    private func logAppearance() {
        print("💸 TransactionsView apareció:")
        print("   📊 \(transactions.count) transacciones totales")
        print("   🔍 \(filteredTransactions.count) transacciones filtradas")
        print("   💳 \(accounts.count) cuentas disponibles")
        print("   💰 Balance neto: \(settings.formatCurrency(netBalance))")
        print("   💱 Divisa actual: \(settings.preferredCurrency) (\(settings.currencySymbol))")
    }
}

// MARK: - TRANSACTION CARD VIEW
struct TransactionCardView: View {
    let transaction: Transaction
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.appTheme) private var theme
    @State private var isVisible = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Enhanced icon
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            transaction.isIncome ? Color.green : Color.red,
                            transaction.isIncome ? Color.green.opacity(0.7) : Color.red.opacity(0.7)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 48, height: 48)
                .overlay(
                    Image(systemName: transaction.categoryIcon)
                        .foregroundStyle(.white)
                        .font(.title3)
                )
                .shadow(
                    color: (transaction.isIncome ? Color.green : Color.red).opacity(0.3),
                    radius: 6,
                    x: 0,
                    y: 3
                )
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(transaction.name)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(formatTransactionAmount(transaction.amount))
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(transaction.isIncome ? Color.green : Color.red)
                        .contentTransition(.numericText())
                }
                
                HStack {
                    Text(transaction.category)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            Color.secondary.opacity(0.2),
                            in: RoundedRectangle(cornerRadius: 6)
                        )
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                        .font(.caption)
                    
                    Text(transaction.accountName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(DateFormatter.shortDate.string(from: transaction.date))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.thinMaterial)
                .stroke(.ultraThinMaterial, lineWidth: 1)
        )
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 10)
        .animation(.smooth(duration: 0.4), value: isVisible)
        .onAppear {
            withAnimation {
                isVisible = true
            }
        }
        .contentShape(Rectangle())
    }
    
    private func formatTransactionAmount(_ amount: Double) -> String {
        let sign = transaction.isIncome ? "+" : ""
        return sign + settings.formatCurrency(amount)
    }
}

// MARK: - TRANSACTION ANALYTICS VIEW
struct TransactionAnalyticsView: View {
    let transactions: [TransactionEntity]
    let totalIncome: Double
    let totalExpenses: Double
    let netBalance: Double
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.appTheme) private var theme
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Resumen financiero
                    VStack(spacing: 16) {
                        Text("Análisis del Período")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        HStack(spacing: 20) {
                            AnalyticsCard(
                                title: "Ingresos",
                                amount: totalIncome,
                                color: .green,
                                icon: "arrow.down.circle.fill"
                            )
                            
                            AnalyticsCard(
                                title: "Gastos",
                                amount: totalExpenses,
                                color: .red,
                                icon: "arrow.up.circle.fill"
                            )
                            
                            AnalyticsCard(
                                title: "Balance",
                                amount: netBalance,
                                color: netBalance >= 0 ? .green : .red,
                                icon: "equal.circle.fill"
                            )
                        }
                    }
                    
                    // Tendencias por mes
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Tendencias Mensuales")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("📈 Gráficos de tendencias próximamente...")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, minHeight: 150)
                            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
                    }
                    
                    // Categorías más gastadas
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Principales Categorías")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("📊 Análisis de categorías próximamente...")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, minHeight: 150)
                            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
                    }
                    
                    Spacer(minLength: 50)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .navigationTitle("Análisis Financiero")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                    .foregroundColor(theme.accentColor)
                }
            }
            .background(.ultraThinMaterial)
        }
    }
}

// MARK: - ANALYTICS CARD COMPONENT
struct AnalyticsCard: View {
    let title: String
    let amount: Double
    let color: Color
    let icon: String
    
    @EnvironmentObject var settings: SettingsManager
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(settings.formatCurrency(amount))
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - ADVANCED FILTERS VIEW
struct AdvancedFiltersView: View {
    @Binding var searchText: String
    @Binding var selectedFilter: String
    @Binding var selectedAccount: String
    let accounts: [AccountEntity]
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.appTheme) private var theme
    
    var body: some View {
        NavigationView {
            Form {
                Section("Filtros Básicos") {
                    TextField("Buscar", text: $searchText)
                    
                    Picker("Tipo", selection: $selectedFilter) {
                        Text("Todas").tag("Todas")
                        Text("Ingresos").tag("Ingresos")
                        Text("Gastos").tag("Gastos")
                    }
                    
                    Picker("Cuenta", selection: $selectedAccount) {
                        Text("Todas").tag("Todas")
                        ForEach(accounts, id: \.id) { account in
                            Text(account.name ?? "").tag(account.name ?? "")
                        }
                    }
                }
                
                Section("Filtros Avanzados") {
                    Text("🔧 Próximamente: Filtros por fecha, rango de montos y más...")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Filtros Avanzados")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Limpiar") {
                        searchText = ""
                        selectedFilter = "Todas"
                        selectedAccount = "Todas"
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Aplicar") {
                        dismiss()
                    }
                    .foregroundColor(theme.accentColor)
                }
            }
        }
    }
}

// MARK: - PREVIEW
#Preview {
    TransactionsView()
        .environmentObject(CoreDataManager.shared)
        .environmentObject(SettingsManager.shared)
        .appTheme(AppTheme())
}
