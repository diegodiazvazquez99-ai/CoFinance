import SwiftUI
import CoreData

// MARK: - SUBSCRIPTIONS VIEW
struct SubscriptionsView: View {
    @EnvironmentObject var coreDataManager: CoreDataManager
    @Environment(\.currencyFormatter) private var currencyFormatter
    @Environment(\.appTheme) private var theme
    
    @State private var searchText = ""
    @State private var selectedAccount = "Todas"
    @State private var showOnlyActive = true
    @State private var showingNewSubscription = false
    @State private var showingEditSubscription = false
    @State private var selectedSubscriptionEntity: SubscriptionEntity?
    
    @FetchRequest(
        entity: AccountEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \AccountEntity.createdAt, ascending: true)]
    ) var accounts: FetchedResults<AccountEntity>
    
    @State private var subscriptions: [SubscriptionEntity] = []
    
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
        return items
    }
    
    private var monthlyTotalEstimate: Double {
        // Aproximación: considerar mensual = 1x, semanal = 4x, anual = (1/12)x, personalizado = 30/intervalDays
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
    
    private var groupedByMonth: [(key: String, value: [SubscriptionEntity])] {
        let grouped = Dictionary(grouping: filteredSubscriptions) { sub in
            DateFormatter.monthYear.string(from: sub.nextChargeDate ?? Date())
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
            .navigationTitle("Suscripciones")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingNewSubscription = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundColor(theme.accentColor)
                    }
                }
            }
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
                    // Persistir cambios
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
    }
    
    private var header: some View {
        VStack(spacing: 16) {
            // Balance/Estimación mensual
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Estimación mensual")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("\(filteredSubscriptions.count) suscripciones")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    Spacer()
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 8, height: 8)
                        .overlay(Circle().stroke(.white, lineWidth: 1))
                }
                Text(currencyFormatter.string(from: NSNumber(value: monthlyTotalEstimate)) ?? "$0.00")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        LinearGradient(colors: [.orange, .orange.opacity(0.7)], startPoint: .leading, endPoint: .trailing)
                    )
                    .contentTransition(.numericText())
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
                    .fill(.regularMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.ultraThinMaterial, lineWidth: 1)
                    )
            )
            
            // Filtros
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    Menu {
                        ForEach(accountOptions, id: \.self) { name in
                            Button(name) { selectedAccount = name }
                        }
                    } label: {
                        filterChip(title: selectedAccount == "Todas" ? "Cuenta: Todas" : "Cuenta: \(selectedAccount)", icon: "creditcard", selected: selectedAccount != "Todas")
                    }
                    
                    Toggle(isOn: $showOnlyActive) {
                        HStack(spacing: 6) {
                            Image(systemName: "bolt.badge.a")
                                .font(.caption)
                            Text("Activas")
                                .font(.subheadline)
                        }
                    }
                    .toggleStyle(.button)
                    .tint(theme.accentColor)
                }
                .padding(.horizontal, 4)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(.ultraThinMaterial)
    }
    
    private var content: some View {
        Group {
            if filteredSubscriptions.isEmpty {
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
                .background(.ultraThinMaterial)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(groupedByMonth, id: \.key) { group in
                            HStack {
                                Text(group.key)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                Spacer()
                                Text("\(group.value.count)")
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(.secondary.opacity(0.2), in: RoundedRectangle(cornerRadius: 6))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(.regularMaterial)
                            
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
                .background(.ultraThinMaterial)
                .refreshable { loadSubscriptions() }
            }
        }
    }
    
    private func filterChip(title: String, icon: String, selected: Bool) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
            Text(title)
                .font(.subheadline)
                .lineLimit(1)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Group {
                if selected {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(theme.accentColor.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(theme.accentColor.opacity(0.3), lineWidth: 1)
                        )
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.regularMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.clear, lineWidth: 1)
                        )
                }
            }
        )
        .foregroundColor(selected ? theme.accentColor : .primary)
    }
    
    private func loadSubscriptions() {
        subscriptions = coreDataManager.fetchSubscriptions()
        print("📄 SubscriptionsView cargó \(subscriptions.count) suscripciones")
    }
}

// MARK: - SUBSCRIPTION CARD
struct SubscriptionCard: View {
    let subscription: Subscription
    let onCharge: () -> Void
    let onTap: () -> Void
    @Environment(\.currencyFormatter) private var currencyFormatter
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
                    Text(currencyFormatter.string(from: NSNumber(value: subscription.amount)) ?? "$0.00")
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

