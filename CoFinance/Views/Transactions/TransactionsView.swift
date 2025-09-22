// TransactionsView.swift
// Vista de Transacciones

import SwiftUI

struct TransactionsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var viewModel: TransactionViewModel
    @State private var searchText = ""
    @State private var showingAddTransaction = false
    @State private var selectedFilter: TransactionType? = nil
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)],
        animation: .smooth
    ) private var transactions: FetchedResults<Transaction>
    
    var filteredTransactions: [Transaction] {
        transactions.filter { transaction in
            let matchesSearch = searchText.isEmpty ||
                transaction.title?.localizedCaseInsensitiveContains(searchText) ?? false
            let matchesFilter = selectedFilter == nil ||
                transaction.type == selectedFilter?.rawValue
            return matchesSearch && matchesFilter
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(groupedTransactions(), id: \.key) { section in
                    Section {
                        ForEach(section.transactions) { transaction in
                            TransactionRow(transaction: transaction)
                                .swipeActions(edge: .trailing) { // iOS 15+
                                    Button(role: .destructive) {
                                        deleteTransaction(transaction)
                                    } label: {
                                        Label("Eliminar", systemImage: "trash")
                                    }
                                }
                        }
                    } header: {
                        Text(section.key)
                            .font(.headline)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .searchable(text: $searchText, prompt: "Buscar transacciones") // iOS 15+
            .navigationTitle("Transacciones")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Transacciones")
                        .font(.largeTitle.bold())
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddTransaction.toggle()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                    }
                }
                
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Menu {
                        Picker("Filtro", selection: $selectedFilter) {
                            Text("Todas").tag(TransactionType?.none)
                            ForEach(TransactionType.allCases, id: \.self) { type in
                                Label(type.title, systemImage: type.icon)
                                    .tag(TransactionType?.some(type))
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .liquidGlassToolbar()
        }
        .sheet(isPresented: $showingAddTransaction) {
            AddTransactionView()
        }
    }
    
    private func groupedTransactions() -> [(key: String, transactions: [Transaction])] {
        let grouped = Dictionary(grouping: filteredTransactions) { transaction in
            formatDate(transaction.date ?? Date())
        }
        return grouped.sorted { $0.key > $1.key }.map { (key: $0.key, transactions: $0.value) }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "es_MX")
        return formatter.string(from: date)
    }
    
    private func deleteTransaction(_ transaction: Transaction) {
        withAnimation {
            viewContext.delete(transaction)
            try? viewContext.save()
        }
    }
}
