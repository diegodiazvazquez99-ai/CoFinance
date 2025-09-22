// SettingsView.swift
// Vista de configuración con panel de desarrollador

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appSettings: AppSettings
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var showingExportOptions = false
    @State private var showingDeveloperPanel = false
    
    var body: some View {
        NavigationView {
            List {
                // Sección General (ya existente en tu app)
                Section("general_title") {
                    HStack {
                        Image(systemName: "globe")
                            .foregroundColor(.blue)
                        
                        Picker("language_title", selection: $appSettings.selectedLanguage) {
                            Text("Español").tag("es")
                            Text("English").tag("en")
                        }
                    }
                    
                    HStack {
                        Image(systemName: "dollarsign.circle")
                            .foregroundColor(.green)
                        
                        Picker("currency_title", selection: $appSettings.selectedCurrency) {
                            Text("MXN - Peso Mexicano").tag("MXN")
                            Text("USD - Dólar").tag("USD")
                            Text("EUR - Euro").tag("EUR")
                        }
                    }
                }
                
                // Sección de Seguridad
                Section("security_title") {
                    Toggle(isOn: $appSettings.enableFaceID) {
                        HStack {
                            Image(systemName: "faceid")
                                .foregroundColor(.blue)
                            Text("enable_faceid")
                        }
                    }
                    
                    Toggle(isOn: $appSettings.enableBiometrics) {
                        HStack {
                            Image(systemName: "lock.shield")
                                .foregroundColor(.orange)
                            Text("enable_biometrics")
                        }
                    }
                }
                
                // Sección de Notificaciones
                Section("notifications_title") {
                    Toggle(isOn: $appSettings.enableNotifications) {
                        HStack {
                            Image(systemName: "bell")
                                .foregroundColor(.red)
                            Text("enable_notifications")
                        }
                    }
                    .disabled(!appSettings.isPushNotificationsEnabled) // Desactivar si no están disponibles
                    
                    if !appSettings.isPushNotificationsEnabled {
                        Text("push_notifications_unavailable")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                
                // Sección de Sincronización
                Section("sync_title") {
                    Toggle(isOn: $appSettings.enableiCloud) {
                        HStack {
                            Image(systemName: "icloud")
                                .foregroundColor(.blue)
                            Text("enable_icloud")
                        }
                    }
                    .disabled(!appSettings.isiCloudEnabled) // Desactivar si no está disponible
                    
                    if !appSettings.isiCloudEnabled {
                        Text("icloud_unavailable")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                
                // 🚀 SECCIÓN DE DESARROLLADOR (Solo en DEBUG)
                #if DEBUG
                Section("🔧 Desarrollador") {
                    Toggle(isOn: $appSettings.developmentMode) {
                        HStack {
                            Image(systemName: "hammer")
                                .foregroundColor(.purple)
                            VStack(alignment: .leading) {
                                Text("Modo Desarrollo")
                                    .font(.headline)
                                Text("Desactivar capacidades premium")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    
                    if appSettings.developmentMode {
                        DeveloperControlsView()
                    }
                }
                #endif
                
                // Sección de Personalización
                Section("appearance_title") {
                    Toggle(isOn: $appSettings.enableHaptics) {
                        HStack {
                            Image(systemName: "iphone.and.arrow.forward")
                                .foregroundColor(.purple)
                            Text("enable_haptics")
                        }
                    }
                }
                
                // Exportar Datos
                Section("data_title") {
                    Button(action: { showingExportOptions = true }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.blue)
                            Text("export_data")
                        }
                    }
                }
            }
            .navigationTitle("settings_title")
            .sheet(isPresented: $showingExportOptions) {
                ExportDataView()
            }
        }
    }
}

// MARK: - Vista de Controles de Desarrollador
#if DEBUG
struct DeveloperControlsView: View {
    @EnvironmentObject private var appSettings: AppSettings
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Divider()
            
            // Control de Push Notifications
            Toggle(isOn: $appSettings.enablePushNotificationsDev) {
                HStack {
                    Image(systemName: "bell.badge")
                        .foregroundColor(.red)
                    VStack(alignment: .leading) {
                        Text("Push Notifications (Dev)")
                            .font(.subheadline)
                        Text("Activar solo para desarrollo")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            // Control de iCloud
            Toggle(isOn: $appSettings.enableiCloudDev) {
                HStack {
                    Image(systemName: "icloud.badge")
                        .foregroundColor(.blue)
                    VStack(alignment: .leading) {
                        Text("iCloud (Dev)")
                            .font(.subheadline)
                        Text("Activar solo para desarrollo")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            // Estado actual
            VStack(alignment: .leading, spacing: 8) {
                Text("Estado Actual:")
                    .font(.caption.weight(.semibold))
                
                HStack {
                    Circle()
                        .fill(appSettings.isPushNotificationsEnabled ? .green : .red)
                        .frame(width: 8, height: 8)
                    Text("Push: \(appSettings.isPushNotificationsEnabled ? "Activo" : "Inactivo")")
                        .font(.caption)
                }
                
                HStack {
                    Circle()
                        .fill(appSettings.isiCloudEnabled ? .green : .red)
                        .frame(width: 8, height: 8)
                    Text("iCloud: \(appSettings.isiCloudEnabled ? "Activo" : "Inactivo")")
                        .font(.caption)
                }
            }
            .padding(.top, 8)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            // Botón para reiniciar la app
            Button("Reiniciar App") {
                exit(0) // Solo para desarrollo
            }
            .foregroundColor(.orange)
            .font(.caption)
        }
    }
}
#endif

#Preview {
    SettingsView()
        .environmentObject(AppSettings())
        .environmentObject(ThemeManager.shared)
}
