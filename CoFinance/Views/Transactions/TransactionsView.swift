import SwiftUI
import Combine
import CoreData

// MARK: - IMPROVED TRANSACTIONS VIEW
struct TransactionsView: View {
    @EnvironmentObject var coreDataManager: CoreDataManager
    @EnvironmentObject var settings: SettingsManager
    @State private var searchText = ""
    @State private var selectedFilter = "Todas"
    @State private var selectedAccount = "Todas"
    @State private var showingNewTransaction = false
    @State private var showingEditTransaction = false
    @State private var selectedTransactionEntity: TransactionEntity?
    @State private var scrollPosition = ScrollPosition(edge: .top)
    @State private var showAccountPickerDialog = false
    @State private var showFilterDialog = false
    
    // 🚀 Environment values
    @Environment(\.appTheme) private var theme
    
    // 🔥 USAR @FetchRequest PARA ACTUALIZACIÓN AUTOMÁTICA
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
        
        // Filtro por búsqueda de texto
        if !searchText.isEmpty {
            filtered = filtered.filter { transaction in
                (transaction.name?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (transaction.category?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (transaction.accountName?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        // Filtro por tipo (Ingresos/Gastos)
        switch selectedFilter {
        case "Ingresos":
            filtered = filtered.filter { $0.isIncome }
        case "Gastos":
            filtered = filtered.filter { !$0.isIncome }
        default:
            break
        }
        
        // Filtro por cuenta
        if selectedAccount != "Todas" {
            filtered = filtered.filter { $0.accountName == selectedAccount }
        }
        
        return filtered
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // MARK: - Header compacto (sin balance card)
                compactHeader
                
                Divider()
                
                // MARK: - Lista de transacciones que ocupa toda la página
                fullScreenTransactionsList
            }
            .navigationTitle("Transacciones")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    modernAddButton
                }
            }
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
    
    // MARK: - HEADER COMPACTO (SIN BALANCE CARD)
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
            
            Text("\(count)")
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(.secondary.opacity(0.15), in: RoundedRectangle(cornerRadius: 6))
                .foregroundColor(.secondary)
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
    
    // MARK: - MODERN ADD BUTTON
    private var modernAddButton: some View {
        Button(action: {
            showingNewTransaction = true
        }) {
            Image(systemName: "plus")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(theme.accentColor)
        }
        .accessibilityLabel("Agregar nueva transacción")
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
    
    private func logAppearance() {
        print("💸 TransactionsView apareció:")
        print("   📊 \(transactions.count) transacciones")
        print("   💳 \(accounts.count) cuentas disponibles")
        print("   💱 Divisa actual: \(settings.preferredCurrency) (\(settings.currencySymbol))")
    }
}

// MARK: - TRANSACTION CARD VIEW (Mantenemos la misma implementación)
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

// MARK: - PREVIEW
#Preview {
    TransactionsView()
        .environmentObject(CoreDataManager.shared)
        .environmentObject(SettingsManager.shared)
        .appTheme(AppTheme())
}
