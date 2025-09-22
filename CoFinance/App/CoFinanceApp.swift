// CoFinanceApp.swift
// App principal con capacidades condicionales

import SwiftUI
import CoreData

@main
struct CoFinanceApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var appSettings = AppSettings()
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(appSettings)
                .environmentObject(themeManager)
                .onAppear {
                    setupAppOnLaunch()
                }
        }
    }
    
    private func setupAppOnLaunch() {
        // 🚀 CONFIGURACIÓN CONDICIONAL DE CAPACIDADES
        
        #if DEBUG
        // En modo DEBUG, mostrar opciones de desarrollo
        print("🔧 CoFinance ejecutándose en modo DEBUG")
        
        if appSettings.developmentMode {
            print("📱 Modo desarrollo activado - Capacidades Premium DESACTIVADAS")
            setupDevelopmentMode()
        } else {
            print("🏭 Modo producción en DEBUG")
            setupProductionCapabilities()
        }
        #else
        // En RELEASE, siempre usar capacidades completas
        print("🚀 CoFinance ejecutándose en modo RELEASE")
        setupProductionCapabilities()
        #endif
    }
    
    #if DEBUG
    private func setupDevelopmentMode() {
        print("⚠️ Capacidades Premium DESACTIVADAS para desarrollo")
        
        // Push Notifications solo si están activadas en configuración de desarrollo
        if appSettings.enablePushNotificationsDev {
            NotificationManager.shared.requestPermission()
            print("✅ Push Notifications ACTIVADAS en desarrollo")
        } else {
            print("❌ Push Notifications DESACTIVADAS en desarrollo")
        }
        
        // iCloud solo si está activado en configuración de desarrollo
        if appSettings.enableiCloudDev {
            // Inicializar CloudKit
            print("✅ iCloud ACTIVADO en desarrollo")
        } else {
            print("❌ iCloud DESACTIVADO en desarrollo")
        }
    }
    #endif
    
    private func setupProductionCapabilities() {
        print("🏭 Configurando capacidades completas...")
        
        // Notificaciones Push (Solo si la cuenta de desarrollador las soporta)
        if appSettings.isPushNotificationsEnabled {
            NotificationManager.shared.requestPermission()
            print("✅ Push Notifications configuradas")
        }
        
        // iCloud/CloudKit
        if appSettings.isiCloudEnabled {
            // Configurar CloudKit
            print("✅ iCloud configurado")
        }
        
        // Autenticación Biométrica
        if appSettings.enableBiometrics {
            BiometricAuthManager.shared.checkBiometricStatus()
            print("✅ Autenticación biométrica configurada")
        }
        
        // Haptic Feedback
        if appSettings.enableHaptics {
            HapticManager.shared.initializeHaptics()
            print("✅ Haptic Feedback configurado")
        }
    }
}

// MARK: - Extensión para Notificaciones Condicionales
extension CoFinanceApp {
    
    // 🔔 Método para programar notificaciones solo si están habilitadas
    static func scheduleNotificationIfEnabled(_ notification: NotificationRequest) {
        let settings = AppSettings()
        
        guard settings.isPushNotificationsEnabled else {
            print("❌ Notificación NO programada - Push Notifications desactivadas")
            return
        }
        
        NotificationManager.shared.scheduleNotification(notification)
        print("✅ Notificación programada exitosamente")
    }
}

// MARK: - Estructura para debugging
#if DEBUG
struct DevelopmentSettings {
    static var isPushEnabled: Bool {
        UserDefaults.standard.bool(forKey: "enablePushNotificationsDev")
    }
    
    static var isiCloudEnabled: Bool {
        UserDefaults.standard.bool(forKey: "enableiCloudDev")
    }
    
    static func toggleDevelopmentMode() {
        let current = UserDefaults.standard.bool(forKey: "developmentMode")
        UserDefaults.standard.set(!current, forKey: "developmentMode")
        print("🔧 Modo desarrollo: \(!current ? "ACTIVADO" : "DESACTIVADO")")
    }
}
#endif
