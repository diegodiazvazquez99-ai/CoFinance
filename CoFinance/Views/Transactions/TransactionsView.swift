// CoFinance/Views/Transactions/TransactionsView.swift
// TRANSACTIONS VIEW OPTIMIZADO PARA iOS 18

import SwiftUI
import Combine
import CoreData

// MARK: - OPTIMIZED TRANSACTIONS VIEW
struct TransactionsView: View {
    @EnvironmentObject var coreDataManager: CoreDataManager
    @State private var searchText = ""
    @State private var selectedFilter = "Todas"
    @State private var selectedAccount = "Todas"
    @State private var showingNewTransaction = false
    @State private var showingEditTransaction = false
    @State private var selectedTransactionEntity: TransactionEntity?
    @State private var scrollPosition = ScrollPosition(edge: .top)
    
    // 🚀 NUEVO: Environment values
    @Environment(\.currencyFormatter) private var currencyFormatter
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
    
    var totalAmount: Double {
        filteredTransactions.reduce(0) { total, transaction in
            total + (transaction.isIncome ? transaction.amount : -transaction.amount)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // MARK: - Header optimizado con filtros
                headerSection
                
                Divider()
                
                // MARK: - Lista de transacciones optimizada
                transactionsList
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
    }
    
    // MARK: - HEADER SECTION OPTIMIZADO
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Balance filtrado modernizado
            modernBalanceCard
            
            // Barra de búsqueda optimizada
            modernSearchBar
            
            // Filtros horizontales mejorados
            modernFiltersSection
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color("AppBackground"))
    }
    
    // MARK: - MODERN BALANCE CARD
    private var modernBalanceCard: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Balance Filtrado")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("\(filteredTransactions.count) transacciones")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                
                Spacer()
                
                // Status indicator
                Circle()
                    .fill(totalAmount >= 0 ? Color.green : Color.red)
                    .frame(width: 8, height: 8)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 1)
                    )
            }
            
            Text(formatCurrency(totalAmount))
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(
                    totalAmount >= 0 ?
                    LinearGradient(
                        colors: [Color.green, Color.green.opacity(0.7)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ) :
                    LinearGradient(
                        colors: [Color.red, Color.red.opacity(0.7)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .contentTransition(.numericText())
                .animation(.smooth(duration: 0.6), value: totalAmount)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: theme.cornerRadius)
                .fill(.thinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: theme.cornerRadius)
                        .stroke(.ultraThinMaterial, lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - MODERN SEARCH BAR
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
    }
    
    // MARK: - MODERN FILTERS SECTION
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
                    showFilterMenu()
                }
                
                // Filtro por cuenta
                FilterButton(
                    title: selectedAccount,
                    icon: "creditcard",
                    isSelected: selectedAccount != "Todas",
                    accentColor: theme.accentColor
                ) {
                    showAccountMenu()
                }
                
                // Botón limpiar filtros
                if selectedFilter != "Todas" || selectedAccount != "Todas" || !searchText.isEmpty {
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
    
    // MARK: - TRANSACTIONS LIST OPTIMIZED
    private var transactionsList: some View {
        Group {
            if filteredTransactions.isEmpty {
                emptyStateView
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(groupedTransactions, id: \.key) { group in
                            modernSectionHeader(for: group.key)
                            
                            ForEach(group.value, id: \.id) { transaction in
                                ModernTransactionCard(transaction: transaction.toTransaction())
                                    .onTapGesture {
                                        selectedTransactionEntity = transaction
                                        showingEditTransaction = true
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 4)
                            }
                        }
                        
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
            DateFormatter.monthYear.string(from: transaction.date ?? Date())
        }
        return grouped.sorted { first, second in
            DateFormatter.monthYear.date(from: first.key) ?? Date() >
            DateFormatter.monthYear.date(from: second.key) ?? Date()
        }
    }
    
    private func modernSectionHeader(for monthYear: String) -> some View {
        HStack {
            Text(monthYear)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Spacer()
            
            // Count for section
            let sectionTransactions = filteredTransactions.filter {
                DateFormatter.monthYear.string(from: $0.date ?? Date()) == monthYear
            }
            
            Text("\(sectionTransactions.count)")
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.secondary.opacity(0.2), in: RoundedRectangle(cornerRadius: 6))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color("AppBackground"))
    }
    
    private func getFilterIcon() -> String {
        switch selectedFilter {
        case "Ingresos": return "arrow.down.circle"
        case "Gastos": return "arrow.up.circle"
        default: return "line.3.horizontal.decrease.circle"
        }
    }
    
    private func showFilterMenu() {
        // Implementar menu de filtros
        print("Show filter menu")
    }
    private func showAccountMenu() {
        // Implementar menu de cuentas
        print("Show account menu")
    }
    
    private func clearFilters() {
        withAnimation(.easeInOut(duration: 0.3)) {
            selectedFilter = "Todas"
            selectedAccount = "Todas"
            searchText = ""
        }
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let sign = amount >= 0 ? "+" : ""
        return sign + (currencyFormatter.string(from: NSNumber(value: abs(amount))) ?? "$\(String(format: "%.2f", abs(amount)))")
    }
    
    private func performRefresh() async {
        print("🔄 Manual refresh en TransactionsView")
        try? await Task.sleep(nanoseconds: 500_000_000)
    }
    
    private func logAppearance() {
        print("💸 TransactionsView apareció:")
        print("   📊 \(transactions.count) transacciones")
        print("   💳 \(accounts.count) cuentas disponibles")
    }
}

// MARK: - FILTER BUTTON COMPONENT
struct FilterButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let accentColor: Color
    let isDestructive: Bool
    let action: () -> Void
    
    init(title: String, icon: String, isSelected: Bool, accentColor: Color, isDestructive: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.isSelected = isSelected
        self.accentColor = accentColor
        self.isDestructive = isDestructive
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.subheadline)
                    .lineLimit(1)
                
                if !isDestructive {
                    Image(systemName: "chevron.down")
                        .font(.caption)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Group {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(accentColor.opacity(0.2))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(accentColor.opacity(0.3), lineWidth: 1)
                            )
                    } else {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.thinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(.clear, lineWidth: 1)
                            )
                    }
                }
            )
            .foregroundColor(isSelected ? accentColor : .primary)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - MODERN TRANSACTION CARD
struct ModernTransactionCard: View {
    let transaction: Transaction
    @Environment(\.currencyFormatter) private var currencyFormatter
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
                    
                    Text((transaction.isIncome ? "+" : "") + formatTransactionAmount(transaction.amount))
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
        return currencyFormatter.string(from: NSNumber(value: amount)) ?? "$\(String(format: "%.2f", amount))"
    }
}

// MARK: - PREVIEW
#Preview {
    TransactionsView()
        .environmentObject(CoreDataManager.shared)
        .appTheme(AppTheme())
}
