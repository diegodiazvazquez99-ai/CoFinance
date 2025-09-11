import SwiftUI

// MARK: - TRANSACTIONS VIEW
struct TransactionsView: View {
    @EnvironmentObject var coreDataManager: CoreDataManager
    @State private var transactions: [TransactionEntity] = []
    @State private var accounts: [AccountEntity] = []
    @State private var searchText = ""
    @State private var selectedFilter = "Todas"
    @State private var selectedAccount = "Todas"
    @State private var showingNewTransaction = false
    @State private var showingEditTransaction = false
    @State private var selectedTransactionEntity: TransactionEntity?
    
    let filterOptions = ["Todas", "Ingresos", "Gastos"]
    
    var accountOptions: [String] {
        var options = ["Todas"]
        options.append(contentsOf: accounts.map { $0.name ?? "" })
        return options
    }
    
    var filteredTransactions: [TransactionEntity] {
        var filtered = transactions
        
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
                // MARK: - Header con filtros
                VStack(spacing: 16) {
                    // Balance filtrado
                    VStack(spacing: 8) {
                        Text("Balance Filtrado")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(totalAmount >= 0 ? "+$\(totalAmount, specifier: "%.2f")" : "$\(totalAmount, specifier: "%.2f")")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(totalAmount >= 0 ? .green : .red)
                            .contentTransition(.numericText())
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    
                    // Barra de búsqueda
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Buscar transacciones...", text: $searchText)
                            .textFieldStyle(.plain)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                    
                    // Filtros horizontales
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            // Filtro por tipo
                            Menu {
                                ForEach(filterOptions, id: \.self) { option in
                                    Button(option) {
                                        selectedFilter = option
                                    }
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: getFilterIcon())
                                    Text(selectedFilter)
                                    Image(systemName: "chevron.down")
                                        .font(.caption)
                                }
                                .font(.subheadline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
                                .foregroundColor(.primary)
                            }
                            
                            // Filtro por cuenta
                            Menu {
                                ForEach(accountOptions, id: \.self) { option in
                                    Button(option) {
                                        selectedAccount = option
                                    }
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "creditcard")
                                    Text(selectedAccount)
                                    Image(systemName: "chevron.down")
                                        .font(.caption)
                                }
                                .font(.subheadline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
                                .foregroundColor(.primary)
                            }
                            
                            // Botón limpiar filtros
                            if selectedFilter != "Todas" || selectedAccount != "Todas" || !searchText.isEmpty {
                                Button(action: {
                                    selectedFilter = "Todas"
                                    selectedAccount = "Todas"
                                    searchText = ""
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "xmark.circle.fill")
                                        Text("Limpiar")
                                    }
                                    .font(.subheadline)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(.red.opacity(0.2), in: RoundedRectangle(cornerRadius: 8))
                                    .foregroundColor(.red)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(.ultraThinMaterial)
                
                Divider()
                
                // MARK: - Lista de transacciones
                if filteredTransactions.isEmpty {
                    // Estado vacío
                    VStack(spacing: 16) {
                        Image(systemName: searchText.isEmpty ? "tray" : "magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                        
                        Text("No hay transacciones")
                            .font(.title2)
                            .fontWeight(.medium)
                        
                        Text(searchText.isEmpty ? "Agrega tu primera transacción" : "No se encontraron resultados para '\(searchText)'")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        if searchText.isEmpty {
                            Button("Crear transacción") {
                                showingNewTransaction = true
                            }
                            .font(.headline)
                            .foregroundColor(.blue)
                            .padding(.top, 8)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.ultraThinMaterial)
                } else {
                    List {
                        ForEach(groupedTransactions, id: \.key) { group in
                            Section(header: sectionHeader(for: group.key)) {
                                ForEach(group.value, id: \.id) { transaction in
                                    TransactionRowDetailedView(transaction: transaction.toTransaction())
                                        .onTapGesture {
                                            selectedTransactionEntity = transaction
                                            showingEditTransaction = true
                                        }
                                        .listRowBackground(Color.clear)
                                        .listRowSeparator(.hidden)
                                        .listRowInsets(EdgeInsets(top: 4, leading: 20, bottom: 4, trailing: 20))
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .background(.ultraThinMaterial)
                    .refreshable {
                        loadTransactions()
                    }
                }
            }
            .navigationTitle("Transacciones")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingNewTransaction = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .onAppear {
            loadTransactions()
        }
        .sheet(isPresented: $showingNewTransaction) {
            NewTransactionView { newTransaction in
                loadTransactions()
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
                        loadTransactions()
                    },
                    onDelete: { transactionToDelete in
                        coreDataManager.deleteTransaction(transactionEntity)
                        loadTransactions()
                    }
                )
            }
        }
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
    
    private func sectionHeader(for monthYear: String) -> some View {
        Text(monthYear)
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(.primary)
            .textCase(nil)
    }
    
    private func getFilterIcon() -> String {
        switch selectedFilter {
        case "Ingresos": return "arrow.down.circle"
        case "Gastos": return "arrow.up.circle"
        default: return "line.3.horizontal.decrease.circle"
        }
    }
    
    private func loadTransactions() {
        transactions = coreDataManager.fetchTransactions()
        accounts = coreDataManager.fetchAccounts()
        
        print("💸 TransactionsView cargó:")
        print("   📊 \(transactions.count) transacciones")
        print("   💳 \(accounts.count) cuentas disponibles")
    }
}
