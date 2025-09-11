import SwiftUI

// MARK: - CONTENT VIEW (FINAL)
struct ContentView: View {
    @State private var selectedTab = 0
    @StateObject private var coreDataManager = CoreDataManager.shared
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // MARK: - Home Tab
            HomeView(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            // MARK: - Accounts Tab
            AccountsView()
                .tabItem {
                    Image(systemName: "creditcard.fill")
                    Text("Cuentas")
                }
                .tag(1)
            
            // MARK: - Transactions Tab
            TransactionsView()
                .tabItem {
                    Image(systemName: "list.bullet.rectangle.fill")
                    Text("Transacciones")
                }
                .tag(2)
            
            // MARK: - Settings Tab
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Ajustes")
                }
                .tag(3)
        }
        .background(.ultraThinMaterial)
        .animation(.easeInOut(duration: 0.3), value: selectedTab)
        .onAppear {
            // Descomenta la línea siguiente si quieres datos de ejemplo
            // coreDataManager.createSampleDataIfNeeded()
            
            print("🚀 CoFinance App iniciada")
            print("📱 Versión refactorizada con \(getFileCount()) archivos organizados")
        }
        .environmentObject(coreDataManager)
    }
    
    // MARK: - Helper Methods
    private func getFileCount() -> Int {
        // Core: 3 archivos (CoreDataManager, View+Extensions, DateFormatter+Extensions)
        // Models: 2 archivos (Account, Transaction)
        // Components: 4 archivos (AnimatedButton, AccountCardView, TransactionComponents, PickerViews)
        // Home: 1 archivo (HomeView)
        // Accounts: 3 archivos (AccountsView, NewAccountView, EditAccountView)
        // Transactions: 3 archivos (TransactionsView, NewTransactionView, EditTransactionView)
        // Main: 2 archivos (CoFinanceApp, ContentView)
        return 18 // Total de archivos en la refactorización
    }
}

// MARK: - PREVIEW
#Preview {
    ContentView()
        .environmentObject(CoreDataManager.shared)
}
