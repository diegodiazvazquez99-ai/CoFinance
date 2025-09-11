import SwiftUI

// MARK: - SETTINGS VIEW
struct SettingsView: View {
    @EnvironmentObject var coreDataManager: CoreDataManager
    @State private var accounts: [AccountEntity] = []
    
    var body: some View {
        NavigationView {
            List {
                // MARK: - Gestión Financiera
                Section {
                    NavigationLink(destination: AccountManagementView()) {
                        HStack {
                            Image(systemName: "creditcard.circle.fill")
                                .foregroundColor(.blue)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Gestión de Cuentas")
                                Text("\(accounts.count) cuenta\(accounts.count == 1 ? "" : "s")")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                } header: {
                    Text("Finanzas")
                }
                
                // MARK: - Configuración de la App
                Section {
                    NavigationLink(destination: NotificationsSettingsView()) {
                        HStack {
                            Image(systemName: "bell.circle.fill")
                                .foregroundColor(.orange)
                            Text("Notificaciones")
                        }
                    }
                    
                    NavigationLink(destination: PrivacySettingsView()) {
                        HStack {
                            Image(systemName: "lock.circle.fill")
                                .foregroundColor(.green)
                            Text("Privacidad y Seguridad")
                        }
                    }
                    
                    NavigationLink(destination: ExportDataView()) {
                        HStack {
                            Image(systemName: "square.and.arrow.up.circle.fill")
                                .foregroundColor(.blue)
                            Text("Exportar Datos")
                        }
                    }
                } header: {
                    Text("Configuración")
                }
                
                // MARK: - Datos y Respaldo
                Section {
                    Button(action: {
                        coreDataManager.createSampleDataIfNeeded()
                        loadAccounts()
                    }) {
                        HStack {
                            Image(systemName: "doc.text.circle.fill")
                                .foregroundColor(.purple)
                            Text("Crear datos de ejemplo")
                        }
                    }
                    
                    NavigationLink(destination: BackupSettingsView()) {
                        HStack {
                            Image(systemName: "icloud.circle.fill")
                                .foregroundColor(.blue)
                            Text("Respaldo y Sincronización")
                        }
                    }
                } header: {
                    Text("Datos")
                } footer: {
                    Text("Los datos de ejemplo te ayudan a probar la aplicación.")
                }
                
                // MARK: - Información de la App
                Section {
                    HStack {
                        Text("Versión")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Arquitectura")
                        Spacer()
                        Text("Refactorizada")
                            .foregroundColor(.secondary)
                    }
                    
                    NavigationLink(destination: AboutView()) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                            Text("Acerca de CoFinance")
                        }
                    }
                    
                    NavigationLink(destination: FeedbackView()) {
                        HStack {
                            Image(systemName: "envelope.circle.fill")
                                .foregroundColor(.blue)
                            Text("Enviar Feedback")
                        }
                    }
                } header: {
                    Text("Acerca de la App")
                }
            }
            .navigationTitle("Ajustes")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            loadAccounts()
        }
    }
    
    private func loadAccounts() {
        accounts = coreDataManager.fetchAccounts()
    }
}

// MARK: - PLACEHOLDER VIEWS (Para navegación futura)
struct NotificationsSettingsView: View {
    var body: some View {
        List {
            Section {
                Text("Configuración de notificaciones")
                Text("Próximamente...")
            }
        }
        .navigationTitle("Notificaciones")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct PrivacySettingsView: View {
    var body: some View {
        List {
            Section {
                Text("Configuración de privacidad")
                Text("Próximamente...")
            }
        }
        .navigationTitle("Privacidad")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct ExportDataView: View {
    var body: some View {
        List {
            Section {
                Text("Exportar datos")
                Text("Próximamente...")
            }
        }
        .navigationTitle("Exportar Datos")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct BackupSettingsView: View {
    var body: some View {
        List {
            Section {
                Text("Configuración de respaldos")
                Text("Próximamente...")
            }
        }
        .navigationTitle("Respaldos")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct AboutView: View {
    var body: some View {
        List {
            Section {
                Text("CoFinance")
                Text("App de gestión financiera personal")
                Text("Versión 1.0.0")
            }
        }
        .navigationTitle("Acerca de")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct FeedbackView: View {
    var body: some View {
        List {
            Section {
                Text("Enviar feedback")
                Text("Próximamente...")
            }
        }
        .navigationTitle("Feedback")
        .navigationBarTitleDisplayMode(.large)
    }
}
