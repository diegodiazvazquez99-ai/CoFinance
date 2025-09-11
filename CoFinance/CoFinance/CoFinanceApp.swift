import SwiftUI

@main
struct CoFinanceApp: App {
    let persistenceController = CoreDataManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.context)
                .environmentObject(CoreDataManager.shared)
        }
    }
}
