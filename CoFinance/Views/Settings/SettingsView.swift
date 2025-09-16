import SwiftUI
import CoreData

// MARK: - SETTINGS VIEW
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var coreDataManager: CoreDataManager
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.appTheme) private var theme
    
    @State private var showingDeleteAlert = false
    @State private var showingAboutSheet = false
    
    var selectedCurrencyInfo: (name: String, symbol: String, flag: String) {
        CurrencyHelper.currencyInfo(for: settings.preferredCurrency) ?? ("Dólar estadounidense", "$", "🇺🇸")
    }
    
    var body: some View {
        NavigationView {
            List {
                // MARK: - Apariencia
                Section {
                    HStack(spacing: 16) {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [theme.accentColor, theme.accentColor.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 32, height: 32)
                            .overlay(
                                Image(systemName: settings.isDarkMode ? "moon.fill" : "sun.max.fill")
                                    .foregroundStyle(.white)
                                    .font(.system(size: 16, weight: .medium))
                            )
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Tema oscuro")
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            Text(settings.isDarkMode ? "Activado" : "Desactivado")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $settings.isDarkMode)
                            .labelsHidden()
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Apariencia")
                } footer: {
                    Text("Cambia entre tema claro y oscuro. La configuración se aplicará inmediatamente.")
                }
                
                // MARK: - Notificaciones
                Section {
                    NavigationLink(destination: NotificationsSettingsView()) {
                        HStack(spacing: 16) {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.orange, Color.orange.opacity(0.7)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Image(systemName: "bell.fill")
                                        .foregroundStyle(.white)
                                        .font(.system(size: 16, weight: .medium))
                                )
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Notificaciones")
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                Text(settings.notificationsEnabled ? "Activadas" : "Desactivadas")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        .padding(.vertical, 4)
                    }
                } header: {
                    Text("Alertas y recordatorios")
                } footer: {
                    Text("Configura qué notificaciones quieres recibir y cuándo.")
                }
                
                // MARK: - Divisa
                Section {
                    NavigationLink(destination: CurrencySettingsView()) {
                        HStack(spacing: 16) {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.green, Color.green.opacity(0.7)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Text(selectedCurrencyInfo.symbol)
                                        .foregroundStyle(.white)
                                        .font(.system(size: 16, weight: .bold))
                                )
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Divisa predeterminada")
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                Text("\(selectedCurrencyInfo.flag) \(selectedCurrencyInfo.name)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        .padding(.vertical, 4)
                    }
                } header: {
                    Text("Configuración regional")
                } footer: {
                    Text("Selecciona la divisa que se usará por defecto en toda la aplicación.")
                }
                
                // MARK: - Zona de Peligro
                Section {
                    Button(action: {
                        showingDeleteAlert = true
                    }) {
                        HStack(spacing: 16) {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.red, Color.red.opacity(0.7)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Image(systemName: "trash.fill")
                                        .foregroundStyle(.white)
                                        .font(.system(size: 16, weight: .medium))
                                )
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Borrar todos los datos")
                                    .font(.body)
                                    .foregroundColor(.red)
                                
                                Text("Esta acción no se puede deshacer")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                } header: {
                    Text("Zona de peligro")
                } footer: {
                    Text("⚠️ Elimina permanentemente todas las cuentas, transacciones y suscripciones.")
                }
                
                // MARK: - Acerca
                Section {
                    Button(action: {
                        showingAboutSheet = true
                    }) {
                        HStack(spacing: 16) {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.indigo, Color.indigo.opacity(0.7)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Image(systemName: "info.circle.fill")
                                        .foregroundStyle(.white)
                                        .font(.system(size: 16, weight: .medium))
                                )
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Acerca de CoFinance")
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                Text("Versión 1.0")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                } header: {
                    Text("Información")
                }
            }
            .scrollContentBackground(.hidden)
            .background(.ultraThinMaterial)
            .navigationTitle("Configuración")
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
        .preferredColorScheme(settings.isDarkMode ? .dark : .light)
        .alert("⚠️ Eliminar todos los datos", isPresented: $showingDeleteAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Eliminar todo", role: .destructive) {
                deleteAllData()
            }
        } message: {
            Text("Esta acción eliminará permanentemente todas tus cuentas, transacciones y suscripciones. No se puede deshacer.")
        }
        .sheet(isPresented: $showingAboutSheet) {
            AboutView()
        }
    }
    
    // MARK: - Delete All Data
    private func deleteAllData() {
        let context = coreDataManager.context
        
        // Eliminar todas las transacciones
        let transactionRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "TransactionEntity")
        let transactionDeleteRequest = NSBatchDeleteRequest(fetchRequest: transactionRequest)
        
        // Eliminar todas las cuentas
        let accountRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "AccountEntity")
        let accountDeleteRequest = NSBatchDeleteRequest(fetchRequest: accountRequest)
        
        // Eliminar todas las suscripciones
        let subscriptionRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "SubscriptionEntity")
        let subscriptionDeleteRequest = NSBatchDeleteRequest(fetchRequest: subscriptionRequest)
        
        do {
            try context.execute(transactionDeleteRequest)
            try context.execute(accountDeleteRequest)
            try context.execute(subscriptionDeleteRequest)
            try context.save()
            print("🗑️ Todos los datos han sido eliminados")
        } catch {
            print("❌ Error eliminando datos: \(error)")
        }
    }
}

// MARK: - ABOUT VIEW
struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.appTheme) private var theme
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // App Icon & Name
                    VStack(spacing: 16) {
                        // App icon placeholder
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [theme.accentColor, theme.accentColor.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                            .overlay(
                                Image(systemName: "dollarsign.circle.fill")
                                    .foregroundStyle(.white)
                                    .font(.system(size: 40, weight: .medium))
                            )
                            .shadow(color: theme.accentColor.opacity(0.3), radius: 10, x: 0, y: 5)
                        
                        VStack(spacing: 8) {
                            Text("CoFinance")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text("Gestión de finanzas personales")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    
                    // Version info
                    VStack(spacing: 12) {
                        InfoRow(title: "Versión", value: "1.0.0")
                        InfoRow(title: "Build", value: "1")
                        InfoRow(title: "iOS mínimo", value: "17.0")
                        InfoRow(title: "Desarrollado con", value: "SwiftUI & iOS 18")
                    }
                    .padding(20)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.ultraThinMaterial, lineWidth: 1)
                    )
                    
                    // Features
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Características")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 12) {
                            FeatureRow(icon: "creditcard.fill", title: "Gestión de cuentas", description: "Administra múltiples cuentas bancarias")
                            FeatureRow(icon: "list.bullet.rectangle.fill", title: "Transacciones", description: "Registra ingresos y gastos fácilmente")
                            FeatureRow(icon: "repeat.circle.fill", title: "Suscripciones", description: "Controla tus suscripciones recurrentes")
                            FeatureRow(icon: "chart.line.uptrend.xyaxis", title: "Resúmenes", description: "Visualiza tu situación financiera")
                        }
                    }
                    .padding(20)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.ultraThinMaterial, lineWidth: 1)
                    )
                    
                    // Footer
                    VStack(spacing: 8) {
                        Text("Hecho con ❤️ usando SwiftUI")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("© 2024 CoFinance")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    Spacer(minLength: 50)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .scrollContentBackground(.hidden)
            .background(.ultraThinMaterial)
            .navigationTitle("Acerca")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                    .foregroundColor(theme.accentColor)
                    .fontWeight(.medium)
                }
            }
        }
    }
}

// MARK: - INFO ROW COMPONENT
struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
    }
}

// MARK: - FEATURE ROW COMPONENT
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.title3)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - PREVIEW
#Preview {
    NavigationView {
        SettingsView()
            .environmentObject(CoreDataManager.shared)
            .environmentObject(SettingsManager.shared)
            .appTheme(AppTheme())
    }
}
