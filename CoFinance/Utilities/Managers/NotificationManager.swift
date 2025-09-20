// NotificationManager.swift
// Gestor de notificaciones locales

import Foundation
import UserNotifications
import SwiftUI

class NotificationManager: NSObject, ObservableObject {
static let shared = NotificationManager()
@Published var hasPermission = false
@Published var pendingNotifications: [UNNotificationRequest] = []

```
override init() {
    super.init()
    checkPermission()
    UNUserNotificationCenter.current().delegate = self
}

/// Solicita permisos de notificación
func requestPermission() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] granted, error in
        DispatchQueue.main.async {
            self?.hasPermission = granted
            if granted {
                print("✅ Permisos de notificación concedidos")
            } else if let error = error {
                print("❌ Error al solicitar permisos: \(error)")
            }
        }
    }
}

/// Verifica si tiene permisos
private func checkPermission() {
    UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
        DispatchQueue.main.async {
            self?.hasPermission = settings.authorizationStatus == .authorized
        }
    }
}

/// Programa una notificación para suscripción
func scheduleSubscriptionReminder(_ subscription: Subscription) {
    guard hasPermission else { 
        print("⚠️ No hay permisos para notificaciones")
        return 
    }
    guard let nextPayment = subscription.nextPaymentDate else { return }
    guard subscription.reminder else { return }
    
    let content = UNMutableNotificationContent()
    content.title = "💳 Recordatorio de pago"
    content.body = "\(subscription.name ?? "Suscripción") - \(subscription.amount.asCurrency)"
    content.sound = .default
    content.badge = 1
    content.categoryIdentifier = "SUBSCRIPTION_PAYMENT"
    
    // Información adicional
    content.userInfo = [
        "subscriptionId": subscription.id?.uuidString ?? "",
        "type": "subscription_payment"
    ]
    
    // Programar para 1 día antes del pago a las 9:00 AM
    let triggerDate = Calendar.current.date(byAdding: .day, value: -1, to: nextPayment) ?? nextPayment
    var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: triggerDate)
    dateComponents.hour = 9
    dateComponents.minute = 0
    
    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
    
    let request = UNNotificationRequest(
        identifier: "subscription_\(subscription.id?.uuidString ?? UUID().uuidString)",
        content: content,
        trigger: trigger
    )
    
    UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
            print("❌ Error al programar notificación: \(error)")
        } else {
            print("✅ Notificación programada para \(subscription.name ?? "")")
        }
    }
}

/// Cancela una notificación
func cancelNotification(for id: String) {
    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
}

/// Programa recordatorio de presupuesto
func scheduleBudgetAlert(_ budget: Budget) {
    guard hasPermission else { return }
    guard budget.alertEnabled else { return }
    
    let percentage = (budget.spent / budget.amount) * 100
    if percentage >= budget.alertPercentage {
        let content = UNMutableNotificationContent()
        content.title = "⚠️ Alerta de presupuesto"
        content.body = "Has alcanzado el \(Int(percentage))% de tu presupuesto de \(budget.name ?? "")"
        content.sound = .defaultCritical
        content.categoryIdentifier = "BUDGET_ALERT"
        
        content.userInfo = [
            "budgetId": budget.id?.uuidString ?? "",
            "type": "budget_alert"
        ]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "budget_\(budget.id?.uuidString ?? UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
}

/// Programa recordatorio diario de registro
func scheduleDailyReminder(at hour: Int = 20) {
    guard hasPermission else { return }
    
    let content = UNMutableNotificationContent()
    content.title = "📊 Registra tus gastos del día"
    content.body = "No olvides registrar tus transacciones de hoy"
    content.sound = .default
    content.categoryIdentifier = "DAILY_REMINDER"
    
    var dateComponents = DateComponents()
    dateComponents.hour = hour
    dateComponents.minute = 0
    
    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
    
    let request = UNNotificationRequest(
        identifier: "daily_reminder",
        content: content,
        trigger: trigger
    )
    
    UNUserNotificationCenter.current().add(request)
}

/// Obtiene todas las notificaciones pendientes
func getPendingNotifications() {
    UNUserNotificationCenter.current().getPendingNotificationRequests { [weak self] requests in
        DispatchQueue.main.async {
            self?.pendingNotifications = requests
        }
    }
}

/// Cancela todas las notificaciones
func cancelAllNotifications() {
    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
}

/// Configura las categorías de notificación
func setupNotificationCategories() {
    // Categoría para pagos de suscripciones
    let payAction = UNNotificationAction(
        identifier: "PAY_ACTION",
        title: "Marcar como pagado",
        options: .foreground
    )
    
    let remindLaterAction = UNNotificationAction(
        identifier: "REMIND_LATER",
        title: "Recordar más tarde",
        options: []
    )
    
    let subscriptionCategory = UNNotificationCategory(
        identifier: "SUBSCRIPTION_PAYMENT",
        actions: [payAction, remindLaterAction],
        intentIdentifiers: [],
        options: []
    )
    
    // Categoría para alertas de presupuesto
    let viewBudgetAction = UNNotificationAction(
        identifier: "VIEW_BUDGET",
        title: "Ver presupuesto",
        options: .foreground
    )
    
    let budgetCategory = UNNotificationCategory(
        identifier: "BUDGET_ALERT",
        actions: [viewBudgetAction],
        intentIdentifiers: [],
        options: []
    )
    
    // Categoría para recordatorio diario
    let addTransactionAction = UNNotificationAction(
        identifier: "ADD_TRANSACTION",
        title: "Agregar transacción",
        options: .foreground
    )
    
    let dailyCategory = UNNotificationCategory(
        identifier: "DAILY_REMINDER",
        actions: [addTransactionAction],
        intentIdentifiers: [],
        options: []
    )
    
    UNUserNotificationCenter.current().setNotificationCategories([
        subscriptionCategory,
        budgetCategory,
        dailyCategory
    ])
}
```

}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationManager: UNUserNotificationCenterDelegate {
// Se llama cuando la app está en primer plano y llega una notificación
func userNotificationCenter(_ center: UNUserNotificationCenter,
willPresent notification: UNNotification,
withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
// Mostrar la notificación aunque la app esté abierta
completionHandler([.banner, .sound, .badge])
}

```
// Se llama cuando el usuario interactúa con la notificación
func userNotificationCenter(_ center: UNUserNotificationCenter, 
                           didReceive response: UNNotificationResponse, 
                           withCompletionHandler completionHandler: @escaping () -> Void) {
    
    let userInfo = response.notification.request.content.userInfo
    
    switch response.actionIdentifier {
    case "PAY_ACTION":
        // Marcar suscripción como pagada
        if let subscriptionId = userInfo["subscriptionId"] as? String {
            // Manejar el pago
            print("Marcar suscripción \(subscriptionId) como pagada")
        }
        
    case "VIEW_BUDGET":
        // Abrir vista de presupuesto
        if let budgetId = userInfo["budgetId"] as? String {
            // Navegar a presupuesto
            print("Ver presupuesto \(budgetId)")
        }
        
    case "ADD_TRANSACTION":
        // Abrir formulario de nueva transacción
        print("Abrir formulario de nueva transacción")
        
    case UNNotificationDefaultActionIdentifier:
        // El usuario tocó la notificación
        print("Notificación tocada")
        
    default:
        break
    }
    
    completionHandler()
}
```

}