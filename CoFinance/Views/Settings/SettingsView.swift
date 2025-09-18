// SettingsView.swift
// Vista de ajustes

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: AppSettings
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Preferencias") {
                    Picker("Moneda", selection: $settings.currency) {
                        Text("MXN").tag("MXN")
                        Text("USD").tag("USD")
                        Text("EUR").tag("EUR")
                    }
                    
                    Picker("Tema", selection: $settings.theme) {
                        ForEach(AppSettings.AppTheme.allCases, id: \.self) { theme in
                            Text(theme.rawValue).tag(theme)
                        }
                    }
                    
                    ColorPicker("Color de acento", selection: $settings.accentColor)
                }
                
                Section("Seguridad") {
                    Toggle("Autenticación biométrica", isOn: $settings.enableBiometrics)
                    Toggle("Notificaciones", isOn: $settings.enableNotifications)
                }
                
                Section("Datos") {
                    Button("Exportar datos") {
                        // Implementar exportación
                    }
                    
                    Button("Hacer respaldo", role: .none) {
                        // Implementar respaldo
                    }
                    .foregroundStyle(.blue)
                    
                    Button("Eliminar todos los datos", role: .destructive) {
                        // Implementar eliminación
                    }
                }
                
                Section {
                    HStack {
                        Text("Versión")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Ajustes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Listo") {
                        dismiss()
                    }
                }
            }
        }
    }
}
