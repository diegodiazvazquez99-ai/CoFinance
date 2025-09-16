import SwiftUI

// MARK: - TABS ENUM (actualizado con Settings)
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
        case .settings: return "Configuración"
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
    @StateObject private var settingsManager = SettingsManager.shared
    
    // 🚀 Theme state
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
        
        // 🚀 Aplicar tema basado en preferencias del usuario
        .preferredColorScheme(settingsManager.isDarkMode ? .dark : .light)
        .appTheme(appTheme)
        .currencyFormatting() // ← NUEVO: Formato de divisa reactivo
        .environmentObject(settingsManager)
        .environmentObject(coreDataManager)
        
        .onAppear {
            print("🚀 CoFinance App iniciada")
            print("📱 Tema: \(settingsManager.isDarkMode ? "Oscuro" : "Claro")")
            print("💱 Divisa: \(settingsManager.preferredCurrency) (\(settingsManager.currencySymbol))")
            print("📊 Usando TabView moderna de iOS 18")
        }
    }
}

// MARK: - PREVIEW
#Preview {
    ContentView()
        .environmentObject(CoreDataManager.shared)
}
