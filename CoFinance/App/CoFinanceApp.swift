// CoFinanceApp.swift
// Archivo principal de la aplicación

import SwiftUI
import CoreData

@main
struct CoFinanceApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var appSettings = AppSettings()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(appSettings)
                .liquidGlassBackground() // Nuevo modificador iOS 26
        }
    }
}
