
import SwiftUI

// MARK: - TABS ENUM (actualizado)
enum CoFinanceTabs: String, CaseIterable, Hashable {
    case home = "home"
    case accounts = "accounts"
    case transactions = "transactions"
    case subscriptions = "subscriptions"
    case settings = "settings"
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .accounts: return "Cuentas"
        case .transactions: return "Transacciones"
        case .subscriptions: return "Suscripciones"
        case .settings: return "Ajustes"
        }
    }
    
    var systemImage: String {
        switch self {
        case .home: return "house.fill"
        case .accounts: return "creditcard.fill"
        case .transactions: return "list.bullet.rectangle.fill"
        case .subscriptions: return "repeat.circle.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

// MARK: - CONTENT VIEW OPTIMIZADO
struct ContentView: View {
    @State private var selectedTab: CoFinanceTabs = .home
    @StateObject private var coreDataManager = CoreDataManager.shared
    
    // 🚀 NUEVO: Theme state
    @State private var appTheme = AppTheme()
    
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
            Tab("Transacc.", systemImage: "list.bullet.rectangle.fill", value: .transactions) {
                TransactionsView()
            }
            
            // MARK: - Subscriptions Tab
            Tab("Suscrip.", systemImage: "repeat.circle.fill", value: .subscriptions) {
                SubscriptionsView()
            }
            
        }
        .tabViewStyle(.sidebarAdaptable) // ← iPad sidebar support
        .background(Color("AppBackground"))
        .animation(.easeInOut(duration: 0.3), value: selectedTab)
        
        // 🚀 NUEVO: Inyectar environment values
        .appTheme(appTheme)
        .environmentObject(coreDataManager)
        
        .onAppear {
            print("🚀 CoFinance App iniciada con @Entry macro")
            print("📱 Usando TabView moderna de iOS 18")
        }
    }
}

// MARK: - PREVIEW
#Preview {
    ContentView()
        .environmentObject(CoreDataManager.shared)
}
