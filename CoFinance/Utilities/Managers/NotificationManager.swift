// NotificationManager.swift
// Administrador de notificaciones con lógica condicional

import UserNotifications
import Foundation

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var hasPermission = false
    @Published var isPushSupported = true // Se determina en runtime
    
    private init() {
        checkNotificationSettings()
        checkPushNotificationSupport()
    }
    
    // 🔍 VERIFICAR SI PUSH NOTIFICATIONS ESTÁN SOPORTADAS
    private func checkPushNotificationSupport() {
        #if DEBUG
            // En desarrollo, revisar si las capacidades están disponibles
            let appSettings = AppSettings()
            if appSettings.developmentMode {
                isPushSupported = appSettings.enablePushNotificationsDev
                print("🔧 Push Notifications Support (Dev): \(isPushSupported)")
            } else {
                isPushSupported = true // En producción dentro de DEBUG
                print("🏭 Push Notifications Support (Prod en Debug): \(isPushSupported)")
            }
        #else
            isPushSupported = true // En release, asumir que están disponibles
            print("🚀 Push Notifications Support (Release): \(isPushSupported)")
        #endif
    }
    
    // 🔔 SOLICITAR PERMISOS (Solo si está soportado)
    func requestPermission() {
        guard isPushSupported else {
            print("❌ Push Notifications no están soportadas - Saltando solicitud de permisos")
            return
        }
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.hasPermission = granted
                
                if granted {
                    print("✅ Permisos de notificación otorgados")
                    self.registerForRemoteNotifications()
                } else if let error = error {
                    print("❌ Error al solicitar permisos: \(error.localizedDescription)")
                } else {
                    print("❌ Permisos de notificación denegados por el usuario")
                }
            }
        }
    }
    
    // 📱 REGISTRAR PARA NOTIFICACIONES REMOTAS
    private func registerForRemoteNotifications() {
        guard isPushSupported else {
            print("❌ Push Notifications no soportadas - No registrando para remotas")
            return
        }
        
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
            print("📱 Registrado para notificaciones remotas")
        }
    }
    
    // 📅 PROGRAMAR NOTIFICACIÓN LOCAL (Funciona sin cuenta pagada)
    func scheduleLocalNotification(
        title: String,
        body: String,
        date: Date,
        identifier: String,
        categoryIdentifier: String? = nil
    ) {
        guard hasPermission else {
            print("❌ No hay permisos para notificaciones")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        if let category = categoryIdentifier {
            content.categoryIdentifier = category
        }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error programando notificación: \(error.localizedDescription)")
            } else {
                print("✅ Notificación local programada: \(title)")
            }
        }
    }
    
    // 💰 RECORDATORIO DE SUSCRIPCIÓN
    func scheduleSubscriptionReminder(_ subscription: Subscription) {
        guard let nextPayment = subscription.nextPaymentDate else { return }
        
        // Programar 1 día antes
        let reminderDate = Calendar.current.date(byAdding: .day, value: -1, to: nextPayment) ?? nextPayment
        
        let title = NSLocalizedString("subscription_reminder_title", comment: "")
        let body = String(format: NSLocalizedString("subscription_reminder_body", comment: ""), subscription.name ?? "", subscription.amount.formatted(.currency(code: "MXN")))
        
        scheduleLocalNotification(
            title: title,
            body: body,
            date: reminderDate,
            identifier: "subscription_\(subscription.objectID)",
            categoryIdentifier: "SUBSCRIPTION_REMINDER"
        )
    }
    
    // 💸 ALERTA DE PRESUPUESTO
    func scheduleBudgetAlert(spent: Double, budget: Double, category: String) {
        let percentage = (spent / budget) * 100
        
        guard percentage >= 80 else { return } // Solo alertar cuando se alcance el 80%
        
        let title: String
        let body: String
        
        if percentage >= 100 {
            title = NSLocalizedString("budget_exceeded_title", comment: "")
            body = String(format: NSLocalizedString("budget_exceeded_body", comment: ""), category)
        } else {
            title = NSLocalizedString("budget_warning_title", comment: "")
            body = String(format: NSLocalizedString("budget_warning_body", comment: ""), Int(percentage), category)
        }
        
        scheduleLocalNotification(
            title: title,
            body: body,
            date: Date().addingTimeInterval(1), // Inmediato
            identifier: "budget_\(category)_\(Date().timeIntervalSince1970)",
            categoryIdentifier: "BUDGET_ALERT"
        )
    }
    
    // 🔍 VERIFICAR CONFIGURACIÓN ACTUAL
    private func checkNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.hasPermission = settings.authorizationStatus == .authorized
            }
        }
    }
    
    // 🗑️ CANCELAR NOTIFICACIONES
    func cancelNotification(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        print("🗑️ Notificación cancelada: \(identifier)")
    }
    
    // 🔄 ACTUALIZAR SOPORTE DE PUSH NOTIFICATIONS
    func refreshPushSupport() {
        checkPushNotificationSupport()
    }
}

// MARK: - Extensión para Mock de Notificaciones (Solo desarrollo)
#if DEBUG
extension NotificationManager {
    
    // 🧪 SIMULAR NOTIFICACIÓN (Para pruebas sin capacidades)
    func simulateNotification(title: String, body: String) {
        print("🧪 SIMULACIÓN DE NOTIFICACIÓN:")
        print("📱 Título: \(title)")
        print("📝 Cuerpo: \(body)")
        print("⏰ Hora: \(Date().formatted())")
        
        // Enviar notificación local inmediata para simular
        if hasPermission {
            scheduleLocalNotification(
                title: "🧪 " + title,
                body: body,
                date: Date().addingTimeInterval(2),
                identifier: "simulation_\(Date().timeIntervalSince1970)"
            )
        }
    }
    
    // 🔧 RESET CONFIGURACIÓN DE DESARROLLO
    func resetDevelopmentSettings() {
        UserDefaults.standard.removeObject(forKey: "developmentMode")
        UserDefaults.standard.removeObject(forKey: "enablePushNotificationsDev")
        UserDefaults.standard.removeObject(forKey: "enableiCloudDev")
        
        refreshPushSupport()
        print("🔧 Configuración de desarrollo reiniciada")
    }
}
#endif
