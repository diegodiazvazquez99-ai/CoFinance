import SwiftUI

// MARK: - NOTIFICATIONS SETTINGS VIEW
struct NotificationsSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.appTheme) private var theme
    
    var body: some View {
        List {
            // MARK: - Configuración Principal
            Section {
                HStack(spacing: 16) {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.orange, Color.orange.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "bell.fill")
                                .foregroundStyle(.white)
                                .font(.system(size: 20, weight: .medium))
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Activar notificaciones")
                            .font(.body)
                            .foregroundColor(.primary)
                        
                        Text(settings.notificationsEnabled ? "Activado" : "Desactivado")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: $settings.notificationsEnabled)
                        .labelsHidden()
                }
                .padding(.vertical, 4)
            } header: {
                Text("Configuración general")
            } footer: {
                Text("Activa o desactiva todas las notificaciones de CoFinance. Cuando esté desactivado, no recibirás ningún tipo de alerta.")
            }
            
            // MARK: - Tipos de Notificaciones (solo si están activadas)
            if settings.notificationsEnabled {
                Section {
                    // Recordatorios de transacciones
                    HStack(spacing: 16) {
                        Circle()
                            .fill(Color.blue.opacity(0.2))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: "clock.fill")
                                    .foregroundColor(.blue)
                                    .font(.system(size: 20, weight: .medium))
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Recordatorios de transacciones")
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            Text("Recordatorios para registrar gastos diarios")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $settings.reminderNotifications)
                            .labelsHidden()
                    }
                    .padding(.vertical, 4)
                    
                    // Alertas de suscripciones
                    HStack(spacing: 16) {
                        Circle()
                            .fill(Color.purple.opacity(0.2))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: "repeat.circle.fill")
                                    .foregroundColor(.purple)
                                    .font(.system(size: 20, weight: .medium))
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Alertas de suscripciones")
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            Text("Notificaciones antes de cobros automáticos")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $settings.subscriptionNotifications)
                            .labelsHidden()
                    }
                    .padding(.vertical, 4)
                    
                    // Recordatorios de transacciones frecuentes
                    HStack(spacing: 16) {
                        Circle()
                            .fill(Color.green.opacity(0.2))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: "arrow.clockwise.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.system(size: 20, weight: .medium))
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Recordatorios de rutina")
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            Text("Alertas para gastos o ingresos recurrentes")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $settings.transactionReminders)
                            .labelsHidden()
                    }
                    .padding(.vertical, 4)
                    
                } header: {
                    Text("Tipos de notificaciones")
                } footer: {
                    Text("Personaliza qué tipo de alertas y recordatorios quieres recibir.")
                }
                
                // MARK: - Configuración Avanzada
                Section {
                    // Horarios de notificaciones
                    HStack(spacing: 16) {
                        Circle()
                            .fill(Color.indigo.opacity(0.2))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: "calendar.circle.fill")
                                    .foregroundColor(.indigo)
                                    .font(.system(size: 20, weight: .medium))
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Horario preferido")
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            Text("9:00 AM - 9:00 PM")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .padding(.vertical, 4)
                    
                    // Frecuencia de recordatorios
                    HStack(spacing: 16) {
                        Circle()
                            .fill(Color.teal.opacity(0.2))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: "timer")
                                    .foregroundColor(.teal)
                                    .font(.system(size: 20, weight: .medium))
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Frecuencia de recordatorios")
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            Text("Diario")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .padding(.vertical, 4)
                    
                } header: {
                    Text("Configuración avanzada")
                } footer: {
                    Text("Próximamente: Configuración de horarios y frecuencia de notificaciones.")
                }
            }
            
            // MARK: - Información de Permisos
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 12) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)
                            .font(.title3)
                        
                        Text("Permisos de notificaciones")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    
                    Text("CoFinance necesita permisos para enviarte notificaciones. Si no recibes alertas, verifica la configuración en Ajustes > Notificaciones > CoFinance.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Button("Abrir Configuración del Sistema") {
                        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsUrl)
                        }
                    }
                    .font(.subheadline)
                    .foregroundColor(theme.accentColor)
                    .padding(.top, 4)
                }
                .padding(.vertical, 8)
            }
        }
        .scrollContentBackground(.hidden)
        .background(.ultraThinMaterial)
        .navigationTitle("Notificaciones")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Listo") {
                    dismiss()
                }
                .foregroundColor(theme.accentColor)
                .fontWeight(.medium)
            }
        }
    }
}

// MARK: - PREVIEW
#Preview {
    NavigationView {
        NotificationsSettingsView()
            .environmentObject(SettingsManager.shared)
            .appTheme(AppTheme())
    }
}
