// CoFinance/Views/SubscriptionsView/SubscriptionsView.swift - TOOLBAR ESPECIALIZADO Y TRANSPARENTE

import SwiftUI
import CoreData

struct SubscriptionsView: View {
    @EnvironmentObject var coreDataManager: CoreDataManager
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.appTheme) private var theme
    
    @State private var searchText = ""
    @State private var selectedAccount = "Todas"
    @State private var showOnlyActive = true
    @State private var showingNewSubscription = false
    @State private var showingEditSubscription = false
    @State private var showingCostAnalysis = false
    @State private var showingBulkActions = false
    @State private var showingExportOptions = false
    @State private var selectedSubscriptionEntity: SubscriptionEntity?
    @State private var showAccountPickerDialog = false
    @State private var viewMode: SubscriptionViewMode = .monthly
    
    @FetchRequest(
        entity: AccountEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \AccountEntity.createdAt, ascending: true)]
    ) var accounts: FetchedResults<AccountEntity>
    
    @State private var subscriptions: [SubscriptionEntity] = []
    
    // MARK: - View Mode Enum
    enum SubscriptionViewMode: String, CaseIterable {
        case monthly = "Mensual"
        case yearly = "Anual"
        case upcoming = "Próximas"
        
        var icon: String {
            switch self {
            case .monthly: return "calendar.badge.clock"
            case .yearly: return "calendar"
            case .upcoming: return "clock.badge.exclamationmark"
            }
        }
    }
    
    private var accountOptions: [String] {
        ["Todas"] + accounts.map { $0.name ?? "" }
    }
    
    private var filteredSubscriptions: [SubscriptionEntity] {
        var items = subscriptions
        
        if !searchText.isEmpty {
            items = items.filter { sub in
                (sub.name?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (sub.category?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (sub.accountName?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        if selectedAccount != "Todas" {
            items = items.filter { $0.accountName == selectedAccount }
        }
        if showOnlyActive {
            items = items.filter { $0.isActive }
        }
        
        // Filtrar por modo de vista
        switch viewMode {
        case .upcoming:
            // Próximas en los siguientes 7 días
            let nextWeek = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
            items = items.filter { sub in
                guard let nextDate = sub.nextChargeDate else { return false }
                return nextDate <= nextWeek && nextDate >= Date()
            }
        case .monthly, .yearly:
            // Sin filtro adicional, solo diferentes cálculos de costos
            break
        }
        
        return items
    }
    
    private var totalCostEstimate: Double {
        switch viewMode {
        case .monthly:
            return monthlyTotalEstimate
        case .yearly:
            return yearlyTotalEstimate
        case .upcoming:
            return upcomingWeekTotal
        }
    }
    
    private var monthlyTotalEstimate: Double {
        filteredSubscriptions.reduce(0.0) { total, sub in
            let base = sub.amount
            let factor: Double
            switch SubscriptionFrequency(rawValue: sub.frequency ?? "") ?? .mensual {
            case .mensual: factor = 1.0
            case .semanal: factor = 4.0
            case .anual: factor = 1.0 / 12.0
            case .personalizado:
                let d = max(1, Int(sub.intervalDays))
                factor = 30.0 / Double(d)
            }
            return total + base * factor
        }
    }
    
    private var yearlyTotalEstimate: Double {
        monthlyTotalEstimate * 12.0
    }
    
    private var upcomingWeekTotal: Double {
        filteredSubscriptions.reduce(0.0) { total, sub in
            total + sub.amount
        }
    }
    
    private var groupedSubscriptions: [(key: String, value: [SubscriptionEntity])] {
        let grouped = Dictionary(grouping: filteredSubscriptions) { sub in
            switch viewMode {
            case .monthly, .yearly:
                return DateFormatter.monthYear.string(from: sub.nextChargeDate ?? Date())
            case .upcoming:
                return formatUpcomingDate(sub.nextChargeDate ?? Date())
            }
        }
        return grouped.sorted { a, b in
            (DateFormatter.monthYear.date(from: a.key) ?? Date()) <
            (DateFormatter.monthYear.date(from: b.key) ?? Date())
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                header
                Divider()
                content
            }
            .navigationBarTitleDisplayMode(.inline)
            // 🚀 TOOLBAR ESPECIALIZADO PARA SUSCRIPCIONES
            .toolbar {
                // LEADING: Análisis y herramientas especializadas
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        // Información de suscripciones
                        Section {
                            Label("\(filteredSubscriptions.count) suscripciones", systemImage: "repeat.circle")
                            Label("Costo \(viewMode.rawValue.lowercased()): \(settings.formatCurrency(totalCostEstimate))", systemImage: "dollarsign.circle")
                        }
                        
                        Divider()
                        
                        // Análisis de costos
                        Section("Análisis") {
                            Button(action: {
                                showingCostAnalysis = true
                            }) {
                                Label("Análisis de costos", systemImage: "chart.pie.fill")
                            }
                            
                            Button(action: {
                                showingBulkActions = true
                            }) {
                                Label("Acciones masivas", systemImage: "slider.horizontal.3")
                            }
                        }
                        
                        Divider()
                        
                        // Exportar y gestión
                        Section("Exportar") {
                            Button(action: {
                                showingExportOptions = true
                            }) {
                                Label("Exportar datos", systemImage: "square.and.arrow.up")
                            }
                            
                            Button(action: {
                                configureReminders()
                            }) {
                                Label("Configurar recordatorios", systemImage: "bell.badge")
                            }
                        }
                        
                        // Cobrar todas las vencidas
                        if hasOverdueSubscriptions {
                            Divider()
                            Button(action: {
                                chargeAllOverdue()
                            }) {
                                Label("Cobrar vencidas (\(overdueCount))", systemImage: "creditcard.and.123")
                            }
                        }
                        
                    } label: {
                        ZStack {
                            Image(systemName: "chart.pie.fill")
                                .font(.title3)
                                .foregroundColor(theme.accentColor)
                            
                            // Badge para suscripciones vencidas
                            if hasOverdueSubscriptions {
                                Circle()
                                    .fill(.red)
                                    .frame(width: 8, height: 8)
                                    .offset(x: 8, y: -8)
                            }
                        }
                    }
                    .accessibilityLabel("Análisis y herramientas de suscripciones")
                }
                
                // PRINCIPAL: Título Suscripciones centrado
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 8) {
                        Image(systemName: "repeat.circle.fill")
                            .font(.title3)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [theme.accentColor, theme.accentColor.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Text("Suscripciones")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                }
                
                // TRAILING: Acciones principales
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    // Vista de modo en iPhone (compacto)
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        Menu {
                            ForEach(SubscriptionViewMode.allCases, id: \.self) { mode in
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        viewMode = mode
                                    }
                                }) {
                                    Label(mode.rawValue, systemImage: mode.icon)
                                }
                            }
                        } label: {
                            Image(systemName: viewMode.icon)
                                .font(.title3)
                                .foregroundColor(theme.accentColor)
                        }
                        .accessibilityLabel("Cambiar vista")
                    }
                    
                    // Total estimado y modo (iPad)
                    if UIDevice.current.userInterfaceIdiom == .pad && !filteredSubscriptions.isEmpty {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(settings.formatCurrency(totalCostEstimate))
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.orange)
                            Text(viewMode.rawValue)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
                    }
                    
                    // Nueva suscripción (acción principal)
                    Button(action: {
                        showingNewSubscription = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(theme.accentColor)
                            .symbolEffect(.bounce.up, options: .nonRepeating)
                    }
                    .accessibilityLabel("Agregar nueva suscripción")
                }
            }
            // 🎨 TOOLBAR STYLING TRANSPARENTE
            .toolbarBackground(.clear, for: .navigationBar)
            .toolbarBackgroundVisibility(.hidden, for: .navigationBar)
            .toolbarColorScheme(settings.isDarkMode ? .dark : .light, for: .navigationBar)
        }
        .onAppear(perform: loadSubscriptions)
        .sheet(isPresented: $showingNewSubscription) {
            NewSubscriptionView {
                loadSubscriptions()
            }
        }
        .sheet(isPresented: $showingEditSubscription) {
            if let sub = selectedSubscriptionEntity {
                EditSubscriptionView(subscription: sub.toSubscription(),
                                     onSave: { updated in
                    coreDataManager.updateSubscription(
                        sub,
                        name: updated.name,
                        amount: updated.amount,
                        frequency: updated.frequency,
                        intervalDays: updated.intervalDays,
                        nextChargeDate: updated.nextChargeDate,
                        accountName: updated.accountName,
                        category: updated.category,
                        notes: updated.notes,
                        isActive: updated.isActive
                    )
                    loadSubscriptions()
                }, onDelete: {
                    coreDataManager.deleteSubscription(sub)
                    loadSubscriptions()
                })
            }
        }
        // 📊 Cost Analysis Sheet
        .sheet(isPresented: $showingCostAnalysis) {
            SubscriptionCostAnalysisView(
                subscriptions: filteredSubscriptions,
                monthlyTotal: monthlyTotalEstimate,
                yearlyTotal: yearlyTotalEstimate
            )
        }
        // ⚙️ Bulk Actions Sheet
        .sheet(isPresented: $showingBulkActions) {
            SubscriptionBulkActionsView(
                subscriptions: subscriptions,
                onActionsCompleted: {
                    loadSubscriptions()
                }
            )
        }
        // 📤 Export Options
        .confirmationDialog("Exportar Suscripciones", isPresented: $showingExportOptions) {
            Button("Calendario de cobros (CSV)") {
                exportSubscriptionCalendar()
            }
            Button("Resumen anual (PDF)") {
                exportYearlySummary()
            }
            Button("Compartir resumen") {
                shareSubscriptionSummary()
            }
            Button("Cancelar", role: .cancel) { }
        } message: {
            Text("Exportar \(filteredSubscriptions.count) suscripciones")
        }
        .confirmationDialog("Selecciona una cuenta", isPresented: $showAccountPickerDialog, titleVisibility: .visible) {
            ForEach(accountOptions, id: \.self) { name in
                Button(name) { selectedAccount = name }
            }
            if selectedAccount != "Todas" {
                Button("Borrar selección", role: .destructive) {
                    selectedAccount = "Todas"
                }
            }
            Button("Cancelar", role: .cancel) { }
        }
    }
    
    // MARK: - HEADER (adaptado con vista de modo)
    private var header: some View {
        VStack(spacing: 16) {
            // Estimación con vista de modo
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(getHeaderTitle())
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("\(filteredSubscriptions.count) suscripciones")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    Spacer()
                    
                    // Indicador del modo de vista
                    HStack(spacing: 4) {
                        Image(systemName: viewMode.icon)
                            .font(.caption)
                        Text(viewMode.rawValue)
                            .font(.caption)
                    }
                    .foregroundColor(theme.accentColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
                }
                
                Text(settings.formatCurrency(totalCostEstimate))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        LinearGradient(colors: [.orange, .orange.opacity(0.7)], startPoint: .leading, endPoint: .trailing)
                    )
                    .contentTransition(.numericText())
                    .animation(.smooth(duration: 0.6), value: totalCostEstimate)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: theme.cornerRadius)
                    .fill(.thinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: theme.cornerRadius)
                            .stroke(.ultraThinMaterial, lineWidth: 1)
                    )
            )
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
            
            // Search
            modernSearchBar
            
            // Filtros
            modernFiltersSection
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color("AppBackground"))
    }
    
    private var modernSearchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
                .font(.system(size: 16, weight: .medium))
            TextField("Buscar suscripciones...", text: $searchText)
                .textFieldStyle(.plain)
                .font(.body)
            if !searchText.isEmpty {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { searchText = "" }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.system(size: 16))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.thinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.ultraThinMaterial, lineWidth: 1)
                )
        )
    }
    
    private var modernFiltersSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                FilterButton(
                    title: selectedAccount == "Todas" ? "Cuenta: Todas" : "Cuenta: \(selectedAccount)",
                    icon: "creditcard",
                    isSelected: selectedAccount != "Todas",
                    accentColor: theme.accentColor
                ) {
                    showAccountPickerDialog = true
                }
                
                FilterButton(
                    title: "Activas",
                    icon: "bolt.badge.a",
                    isSelected: showOnlyActive,
                    accentColor: theme.accentColor
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showOnlyActive.toggle()
                    }
                }
                
                if selectedAccount != "Todas" || !showOnlyActive || !searchText.isEmpty {
                    FilterButton(
                        title: "Limpiar",
                        icon: "xmark.circle.fill",
                        isSelected: false,
                        accentColor: .red,
                        isDestructive: true
                    ) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedAccount = "Todas"
                            showOnlyActive = true
                            searchText = ""
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - CONTENT
    private var content: some View {
        Group {
            if filteredSubscriptions.isEmpty {
                emptyStateView
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(groupedSubscriptions, id: \.key) { group in
                            sectionHeader(for: group.key, count: group.value.count)
                            
                            ForEach(group.value, id: \.id) { sub in
                                SubscriptionCard(subscription: sub.toSubscription(),
                                                 onCharge: {
                                    coreDataManager.chargeSubscriptionNow(sub)
                                    loadSubscriptions()
                                }, onTap: {
                                    selectedSubscriptionEntity = sub
                                    showingEditSubscription = true
                                })
                                .padding(.horizontal, 20)
                                .padding(.vertical, 6)
                            }
                        }
                        Spacer(minLength: 100)
                    }
                }
                .background(Color("AppBackground"))
                .refreshable { loadSubscriptions() }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: searchText.isEmpty ? "tray" : "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
                .symbolEffect(.pulse.wholeSymbol, options: .repeating)
            Text("No hay suscripciones")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            Text(searchText.isEmpty ? "Agrega tu primera suscripción" : "No se encontraron resultados para '\(searchText)'")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            if searchText.isEmpty {
                Button("Crear suscripción") { showingNewSubscription = true }
                    .font(.headline)
                    .foregroundColor(theme.accentColor)
                    .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("AppBackground"))
    }
    
    private func sectionHeader(for group: String, count: Int) -> some View {
        HStack {
            Text(group)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                // Calcular total del grupo
                let groupTotal = groupedSubscriptions.first { $0.key == group }?.value.reduce(0.0) { total, sub in
                    total + sub.amount
                } ?? 0.0
                
                Text(settings.formatCurrency(groupTotal))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
                
                Text("\(count)")
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.secondary.opacity(0.2), in: RoundedRectangle(cornerRadius: 4))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color("AppBackground"))
    }
    
    // MARK: - Helper Properties
    private var hasOverdueSubscriptions: Bool {
        subscriptions.contains { sub in
            guard let nextDate = sub.nextChargeDate else { return false }
            return nextDate < Date() && sub.isActive
        }
    }
    
    private var overdueCount: Int {
        subscriptions.filter { sub in
            guard let nextDate = sub.nextChargeDate else { return false }
            return nextDate < Date() && sub.isActive
        }.count
    }
    
    // MARK: - Helper Methods
    private func getHeaderTitle() -> String {
        switch viewMode {
        case .monthly: return "Estimación mensual"
        case .yearly: return "Estimación anual"
        case .upcoming: return "Próximos 7 días"
        }
    }
    
    private func formatUpcomingDate(_ date: Date) -> String {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
        switch days {
        case 0: return "Hoy"
        case 1: return "Mañana"
        case 2...7: return "En \(days) días"
        default: return "Más tarde"
        }
    }
    
    private func loadSubscriptions() {
        subscriptions = coreDataManager.fetchSubscriptions()
        print("📄 SubscriptionsView cargó \(subscriptions.count) suscripciones")
        print("💱 Divisa actual: \(settings.preferredCurrency) (\(settings.currencySymbol))")
    }
    
    // MARK: - Action Methods
    private func configureReminders() {
        print("🔔 Configurando recordatorios...")
        // TODO: Implementar configuración de recordatorios
    }
    
    private func chargeAllOverdue() {
        print("💳 Cobrando \(overdueCount) suscripciones vencidas...")
        let overdueSubscriptions = subscriptions.filter { sub in
            guard let nextDate = sub.nextChargeDate else { return false }
            return nextDate < Date() && sub.isActive
        }
        
        for subscription in overdueSubscriptions {
            coreDataManager.chargeSubscriptionNow(subscription)
        }
        
        loadSubscriptions()
    }
    
    private func exportSubscriptionCalendar() {
        print("📅 Exportando calendario de cobros...")
        
        // Estructura CSV para calendario
        let csvHeader = "Nombre,Monto,Frecuencia,Próximo Cobro,Cuenta,Categoría,Activa"
        var csvContent = csvHeader + "\n"
        
        for sub in filteredSubscriptions {
            let nextDateStr = DateFormatter.mediumDate.string(from: sub.nextChargeDate ?? Date())
            let activeStr = sub.isActive ? "Sí" : "No"
            let row = "\(sub.name ?? ""),\(sub.amount),\(sub.frequency ?? ""),\(nextDateStr),\(sub.accountName ?? ""),\(sub.category ?? ""),\(activeStr)"
            csvContent += row + "\n"
        }
        
        print("📄 Calendario CSV generado con \(filteredSubscriptions.count) suscripciones")
    }
    
    private func exportYearlySummary() {
        print("📄 Exportando resumen anual...")
        // TODO: Implementar exportación de resumen anual
    }
    
    private func shareSubscriptionSummary() {
        let summary = """
        🔄 Resumen de Suscripciones - CoFinance
        
        📊 Total de Suscripciones: \(filteredSubscriptions.count)
        🔵 Activas: \(filteredSubscriptions.filter { $0.isActive }.count)
        
        💰 Costo Mensual: \(settings.formatCurrency(monthlyTotalEstimate))
        📅 Costo Anual: \(settings.formatCurrency(yearlyTotalEstimate))
        
        ⚠️ Vencidas: \(overdueCount)
        
        Generado: \(DateFormatter.mediumDate.string(from: Date()))
        """
        
        print("📝 Resumen compartido: \(summary)")
        // TODO: Implementar UIActivityViewController
    }
}

// MARK: - SUBSCRIPTION CARD
struct SubscriptionCard: View {
    let subscription: Subscription
    let onCharge: () -> Void
    let onTap: () -> Void
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.appTheme) private var theme
    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(
                    LinearGradient(colors: [.orange, .orange.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .frame(width: 48, height: 48)
                .overlay(
                    Image(systemName: "repeat.circle.fill")
                        .foregroundStyle(.white)
                        .font(.title3)
                )
                .shadow(color: Color.orange.opacity(0.3), radius: 6, x: 0, y: 3)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(subscription.name)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    Spacer()
                    Text(settings.formatCurrency(subscription.amount))
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                
                HStack {
                    Text(subscription.category)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.secondary.opacity(0.2), in: RoundedRectangle(cornerRadius: 6))
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                        .font(.caption)
                    
                    Text(subscription.accountName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text("Próximo: \(DateFormatter.shortDate.string(from: subscription.nextChargeDate))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Button(action: onCharge) {
                Image(systemName: "creditcard.and.123")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle().fill(
                            LinearGradient(colors: [theme.accentColor, theme.accentColor.opacity(0.8)],
                                           startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Registrar cobro")
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.thinMaterial)
                .stroke(.ultraThinMaterial, lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
}

// MARK: - SUBSCRIPTION COST ANALYSIS VIEW
struct SubscriptionCostAnalysisView: View {
    let subscriptions: [SubscriptionEntity]
    let monthlyTotal: Double
    let yearlyTotal: Double
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.appTheme) private var theme
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Resumen de costos
                    VStack(spacing: 16) {
                        Text("Análisis de Costos")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        HStack(spacing: 20) {
                            CostAnalysisCard(
                                title: "Mensual",
                                amount: monthlyTotal,
                                color: .orange,
                                icon: "calendar.badge.clock"
                            )
                            
                            CostAnalysisCard(
                                title: "Anual",
                                amount: yearlyTotal,
                                color: .purple,
                                icon: "calendar"
                            )
                        }
                    }
                    
                    // Distribución por categoría
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Por Categoría")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("📊 Gráfico de distribución próximamente...")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, minHeight: 200)
                            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
                    }
                    
                    Spacer(minLength: 50)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .navigationTitle("Análisis de Costos")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                    .foregroundColor(theme.accentColor)
                }
            }
            .background(.ultraThinMaterial)
        }
    }
}

// MARK: - COST ANALYSIS CARD COMPONENT
struct CostAnalysisCard: View {
    let title: String
    let amount: Double
    let color: Color
    let icon: String
    
    @EnvironmentObject var settings: SettingsManager
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(settings.formatCurrency(amount))
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - BULK ACTIONS VIEW
struct SubscriptionBulkActionsView: View {
    let subscriptions: [SubscriptionEntity]
    let onActionsCompleted: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.appTheme) private var theme
    
    var body: some View {
        NavigationView {
            List {
                Section("Acciones Masivas") {
                    Button("Activar todas las suscripciones") {
                        print("🔄 Activando todas las suscripciones...")
                        onActionsCompleted()
                        dismiss()
                    }
                    
                    Button("Desactivar todas las suscripciones") {
                        print("⏸️ Desactivando todas las suscripciones...")
                        onActionsCompleted()
                        dismiss()
                    }
                    
                    Button("Actualizar fechas de cobro") {
                        print("📅 Actualizando fechas de cobro...")
                        onActionsCompleted()
                        dismiss()
                    }
                }
                
                Section("Información") {
                    Text("🔧 Funciones de acciones masivas próximamente...")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Acciones Masivas")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .foregroundColor(theme.accentColor)
                }
            }
        }
    }
}

// MARK: - PREVIEW
#Preview {
    SubscriptionsView()
        .environmentObject(CoreDataManager.shared)
        .environmentObject(SettingsManager.shared)
        .appTheme(AppTheme())
}
