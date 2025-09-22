// ContentView.swift
// Vista principal con Tab Bar

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: TabItem = .home
    @StateObject private var transactionViewModel = TransactionViewModel()
    @StateObject private var subscriptionViewModel = SubscriptionViewModel()
    @StateObject private var accountViewModel = AccountViewModel()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(TabItem.home.title, systemImage: TabItem.home.icon, value: .home) {
                HomeView()
            }
            
            Tab(TabItem.transactions.title, systemImage: TabItem.transactions.icon, value: .transactions) {
                TransactionsView()
                    .environmentObject(transactionViewModel)
            }
            
            Tab(TabItem.subscriptions.title, systemImage: TabItem.subscriptions.icon, value: .subscriptions) {
                SubscriptionsView()
                    .environmentObject(subscriptionViewModel)
            }
            
            Tab(TabItem.accounts.title, systemImage: TabItem.accounts.icon, value: .accounts) {
                AccountsView()
                    .environmentObject(accountViewModel)
            }
        }
        .tabViewStyle(.floatingBar) // Nuevo estilo iOS 26 Liquid Glass
        .adaptiveTabBar() // Tab bar adaptativa iOS 26
    }
}
