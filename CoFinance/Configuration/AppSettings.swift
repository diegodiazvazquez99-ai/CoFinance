// AppSettings.swift
// Configuración global de la app

import SwiftUI
import Combine

class AppSettings: ObservableObject {
    @Published var currency = "MXN"
    @Published var enableNotifications = true
    @Published var enableBiometrics = false
    @Published var theme: AppTheme = .system
    @Published var accentColor: Color = .blue
    
    enum AppTheme: String, CaseIterable {
        case light = "Claro"
        case dark = "Oscuro"
        case system = "Sistema"
    }
}
