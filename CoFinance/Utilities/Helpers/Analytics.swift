// Analytics.swift
// Sistema de analíticas

import Foundation
import SwiftUI

class Analytics: ObservableObject {
static let shared = Analytics()

```
@Published var events: [AnalyticsEvent] = []
@Published var sessionStartTime: Date
@Published var screenViews: [String: Int] = [:]
@Published var userActions: [String: Int] = [:]

private init() {
    sessionStartTime = Date()
    loadStoredAnalytics()
}

// MARK: - Event Tracking

/// Registra un evento
func track(event: String, parameters: [String: Any]? = nil) {
    let analyticsEvent = AnalyticsEvent(
        name: event,
        parameters: parameters,
        timestamp: Date()
    )
    
    events.append(analyticsEvent)
    
    #if DEBUG
    print("📊 Analytics Event: \(event)")
    if let parameters = parameters {
        print("   Parameters: \(parameters)")
    }
    #endif
    
    // Actualizar contadores
    updateCounters(event: event)
    
    // Guardar periódicamente
    if events.count % 10 == 0 {
        saveAnalytics()
    }
    
    // Enviar a servicio externo (si está configurado)
    sendToAnalyticsService(event: analyticsEvent)
}

/// Registra vista de pantalla
func trackScreenView(_ screenName: String) {
    screenViews[screenName, default: 0] += 1
    track(event: Event.screenView, parameters: ["screen": screenName])
}

/// Registra acción de usuario
func trackUserAction(_ action: String, target: String? = nil) {
    userActions[action, default: 0] += 1
    var params: [String: Any] = ["action": action]
    if let target = target {
        params["target"] = target
    }
    track(event: Event.userAction, parameters: params)
}

// MARK: - Eventos predefinidos

enum Event {
    // App lifecycle
    static let appOpened = "app_opened"
    static let appClosed = "app_closed"
    static let appBackgrounded = "app_backgrounded"
    static let appForegrounded = "app_foregrounded"
    
    // Navigation
    static let screenView = "screen_view"
    static let tabChanged = "tab_changed"
    static let userAction = "user_action"
    
    // Transacciones
    static let transactionAdded = "transaction_added"
    static let transactionEdited = "transaction_edited"
    static let transactionDeleted = "transaction_deleted"
    
    // Suscripciones
    static let subscriptionAdded = "subscription_added"
    static let subscriptionEdited = "subscription_edited"
    static let subscriptionDeleted = "subscription_deleted"
    static let subscriptionPaused = "subscription_paused"
    static let subscriptionResumed = "subscription_resumed"
    
    // Cuentas
    static let accountAdded = "account_added"
    static let accountEdited = "account_edited"
    static let accountDeleted = "account_deleted"
    static let fundsTransferred = "funds_transferred"
    
    // Presupuesto y metas
    static let budgetCreated = "budget_created"
    static let budgetExceeded = "budget_exceeded"
    static let goalCreated = "goal_created"
    static let goalCompleted = "goal_completed"
    
    // Settings
    static let settingsChanged = "settings_changed"
    static let biometricsEnabled = "biometrics_enabled"
    static let biometricsDisabled = "biometrics_disabled"
    static let notificationsEnabled = "notifications_enabled"
    static let notificationsDisabled = "notifications_disabled"
    
    // Exportación
    static let dataExported = "data_exported"
    static let dataImported = "data_imported"
    static let reportGenerated = "report_generated"
    
    // Errores
    static let errorOccurred = "error_occurred"
    static let crashDetected = "crash_detected"
}

// MARK: - Métricas

/// Calcula el tiempo de sesión
var sessionDuration: TimeInterval {
    Date().timeIntervalSince(sessionStartTime)
}

/// Pantalla más vista
var mostViewedScreen: String? {
    screenViews.max(by: { $0.value < $1.value })?.key
}

/// Acción más frecuente
var mostFrequentAction: String? {
    userActions.max(by: { $0.value < $1.value })?.key
}

/// Total de eventos en la sesión
var totalEvents: Int {
    events.count
}

/// Eventos por minuto
var eventsPerMinute: Double {
    let minutes = sessionDuration / 60
    return minutes > 0 ? Double(totalEvents) / minutes : 0
}

// MARK: - Reportes

/// Genera reporte de uso diario
func generateDailyReport() -> UsageReport {
    let today = Date()
    let startOfDay = Calendar.current.startOfDay(for: today)
    
    let todayEvents = events.filter { event in
        event.timestamp >= startOfDay
    }
    
    return UsageReport(
        date: today,
        totalEvents: todayEvents.count,
        uniqueScreens: Set(todayEvents.compactMap { $0.parameters?["screen"] as? String }).count,
        topEvents: getTopEvents(from: todayEvents),
        sessionDuration: sessionDuration
    )
}

/// Obtiene los eventos más frecuentes
private func getTopEvents(from events: [AnalyticsEvent]) -> [(String, Int)] {
    let grouped = Dictionary(grouping: events, by: { $0.name })
    return grouped
        .map { ($0.key, $0.value.count) }
        .sorted { $0.1 > $1.1 }
        .prefix(5)
        .map { $0 }
}

// MARK: - Persistencia

/// Guarda analíticas en UserDefaults
private func saveAnalytics() {
    // Limitar a últimos 1000 eventos
    let recentEvents = events.suffix(1000)
    
    let encoder = JSONEncoder()
    if let encoded = try? encoder.encode(Array(recentEvents)) {
        UserDefaults.standard.set(encoded, forKey: "AnalyticsEvents")
    }
    
    // Guardar contadores
    UserDefaults.standard.set(screenViews, forKey: "AnalyticsScreenViews")
    UserDefaults.standard.set(userActions, forKey: "AnalyticsUserActions")
}

/// Carga analíticas guardadas
private func loadStoredAnalytics() {
    let decoder = JSONDecoder()
    
    if let data = UserDefaults.standard.data(forKey: "AnalyticsEvents"),
       let decoded = try? decoder.decode([AnalyticsEvent].self, from: data) {
        events = decoded
    }
    
    if let views = UserDefaults.standard.dictionary(forKey: "AnalyticsScreenViews") as? [String: Int] {
        screenViews = views
    }
    
    if let actions = UserDefaults.standard.dictionary(forKey: "AnalyticsUserActions") as? [String: Int] {
        userActions = actions
    }
}

/// Limpia datos antiguos
func cleanOldData(olderThan days: Int = 30) {
    let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
    events = events.filter { $0.timestamp > cutoffDate }
    saveAnalytics()
}

// MARK: - Integración con servicios externos

private func sendToAnalyticsService(event: AnalyticsEvent) {
    // Aquí irían las llamadas a servicios como:
    // - Firebase Analytics
    // - Mixpanel
    // - Amplitude
    // - Segment
    // - Custom backend
    
    #if !DEBUG
    // Solo enviar en producción
    // FirebaseAnalytics.logEvent(event.name, parameters: event.parameters)
    #endif
}

private func updateCounters(event: String) {
    // Actualizar contadores específicos según el evento
    switch event {
    case Event.transactionAdded,
         Event.subscriptionAdded,
         Event.accountAdded:
        UserDefaults.standard.set(
            UserDefaults.standard.integer(forKey: "TotalItemsCreated") + 1,
            forKey: "TotalItemsCreated"
        )
    default:
        break
    }
}
```

}

// MARK: - Analytics Event Model
struct AnalyticsEvent: Codable, Identifiable {
let id = UUID()
let name: String
let parameters: [String: Any]?
let timestamp: Date

```
enum CodingKeys: String, CodingKey {
    case name, timestamp
}

init(name: String, parameters: [String: Any]?, timestamp: Date) {
    self.name = name
    self.parameters = parameters
    self.timestamp = timestamp
}

// Custom encoding/decoding para manejar Any
init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    name = try container.decode(String.self, forKey: .name)
    timestamp = try container.decode(Date.self, forKey: .timestamp)
    parameters = nil // Simplificado para evitar complejidad
}

func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(name, forKey: .name)
    try container.encode(timestamp, forKey: .timestamp)
}
```

}

// MARK: - Usage Report Model
struct UsageReport {
let date: Date
let totalEvents: Int
let uniqueScreens: Int
let topEvents: [(String, Int)]
let sessionDuration: TimeInterval

```
var formattedDuration: String {
    let hours = Int(sessionDuration) / 3600
    let minutes = (Int(sessionDuration) % 3600) / 60
    let seconds = Int(sessionDuration) % 60
    
    if hours > 0 {
        return "\(hours)h \(minutes)m"
    } else if minutes > 0 {
        return "\(minutes)m \(seconds)s"
    } else {
        return "\(seconds)s"
    }
}
```

}

// MARK: - Analytics View Modifier
struct AnalyticsViewModifier: ViewModifier {
let screenName: String

```
func body(content: Content) -> some View {
    content
        .onAppear {
            Analytics.shared.trackScreenView(screenName)
        }
}
```

}

extension View {
func trackScreen(_ name: String) -> some View {
modifier(AnalyticsViewModifier(screenName: name))
}
}

// MARK: - Analytics Dashboard View
struct AnalyticsDashboardView: View {
@StateObject private var analytics = Analytics.shared

```
var body: some View {
    NavigationStack {
        List {
            Section("Sesión actual") {
                DetailRow(
                    label: "Duración",
                    value: formatDuration(analytics.sessionDuration),
                    icon: "clock"
                )
                
                DetailRow(
                    label: "Eventos totales",
                    value: "\(analytics.totalEvents)",
                    icon: "chart.bar"
                )
                
                DetailRow(
                    label: "Eventos por minuto",
                    value: String(format: "%.1f", analytics.eventsPerMinute),
                    icon: "speedometer"
                )
            }
            
            Section("Pantallas más vistas") {
                ForEach(analytics.screenViews.sorted(by: { $0.value > $1.value }).prefix(5), id: \.key) { screen, count in
                    HStack {
                        Text(screen)
                            .font(.subheadline)
                        Spacer()
                        Text("\(count)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Section("Acciones frecuentes") {
                ForEach(analytics.userActions.sorted(by: { $0.value > $1.value }).prefix(5), id: \.key) { action, count in
                    HStack {
                        Text(action)
                            .font(.subheadline)
                        Spacer()
                        Text("\(count)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Section("Eventos recientes") {
                ForEach(analytics.events.suffix(10).reversed()) { event in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(event.name)
                            .font(.subheadline)
                        Text(event.timestamp.formatted(date: .omitted, time: .shortened))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Analíticas")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private func formatDuration(_ duration: TimeInterval) -> String {
    let hours = Int(duration) / 3600
    let minutes = (Int(duration) % 3600) / 60
    
    if hours > 0 {
        return "\(hours)h \(minutes)m"
    } else {
        return "\(minutes)m"
    }
}
```

}