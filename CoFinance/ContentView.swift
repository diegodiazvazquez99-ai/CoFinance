import SwiftUI

// MARK: - TABS ENUM
enum CoFinanceTabs: String, CaseIterable {
    case home = "home"
    case accounts = "accounts"
    case transactions = "transactions"
    case settings = "settings"
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .accounts: return "Cuentas"
        case .transactions: return "Transacciones"
        case .settings: return "Ajustes"
        }
    }
    
    var systemImage: String {
        switch self {
        case .home: return "house.fill"
        case .accounts: return "creditcard.fill"
        case .transactions: return "list.bullet.rectangle.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

// MARK: - CONTENT VIEW (MODERNIZED)
struct ContentView: View {
    @State private var selectedTab: CoFinanceTabs = .home
    @StateObject private var coreDataManager = CoreDataManager.shared
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            // MARK: - Home Tab
            Tab("Home", systemImage: "house.fill", value: .home) {
                HomeView(selectedTab: $selectedTab)
            }
            
            // MARK: - Accounts Tab
            Tab("Cuentas", systemImage: "creditcard.fill", value: .accounts) {
                AccountsView()
            }
            
            // MARK: - Transactions Tab
            Tab("Transacciones", systemImage: "list.bullet.rectangle.fill", value: .transactions) {
                TransactionsView()
            }
            
            // MARK: - Settings Tab
            Tab("Ajustes", systemImage: "gearshape.fill", value: .settings) {
                SettingsView()
            }
        }
        .tabViewStyle(.sidebarAdaptable) // ← iPad sidebar support
        .background(.ultraThinMaterial)
        .animation(.easeInOut(duration: 0.3), value: selectedTab)
        .onAppear {
            print("🚀 CoFinance App iniciada con nueva API")
            print("📱 Usando TabView moderna de iOS 18")
        }
        .environmentObject(coreDataManager)
    }
}

// MARK: - PREVIEW
#Preview {
    ContentView()
        .environmentObject(CoreDataManager.shared)
}
