// AccountsView.swift
// Vista de Cuentas

import SwiftUI

struct AccountsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var viewModel: AccountViewModel
    @State private var showingAddAccount = false
    @State private var selectedAccount: Account?
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Account.balance, ascending: false)],
        animation: .smooth
    ) private var accounts: FetchedResults<Account>
    
    var totalBalance: Double {
        accounts.reduce(0) { $0 + $1.balance }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Total de todas las cuentas
                    TotalBalanceCard(
                        totalBalance: totalBalance,
                        accountsCount: accounts.count
                    )
                    .padding(.horizontal)
                    
                    // Lista de cuentas
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Mis cuentas")
                                .font(.headline)
                            Spacer()
                            Text("\(accounts.count) cuentas")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal)
                        
                        if accounts.isEmpty {
                            EmptyStateView(
                                icon: "creditcard",
                                title: "Sin cuentas",
                                message: "Agrega tus cuentas bancarias y tarjetas para un mejor control financiero"
                            )
                            .padding()
                        } else {
                            ForEach(accounts) { account in
                                AccountCardView(account: account)
                                    .padding(.horizontal)
                                    .onTapGesture {
                                        selectedAccount = account
                                    }
                            }
                        }
                    }
                    
                    // Distribución de fondos
                    if !accounts.isEmpty {
                        FundsDistributionChart(accounts: Array(accounts))
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Cuentas")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("Cuentas")
                        .font(.largeTitle.bold())
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddAccount.toggle()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
            .liquidGlassToolbar()
        }
        .sheet(isPresented: $showingAddAccount) {
            AddAccountView()
        }
        .sheet(item: $selectedAccount) { account in
            AccountDetailView(account: account)
                .presentationDetents([.large])
                .presentationBackground(Material.liquidGlass)
        }
    }
}
