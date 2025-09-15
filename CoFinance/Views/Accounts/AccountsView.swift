import SwiftUI
import Combine
import CoreData

// MARK: - ACCOUNTS VIEW
struct AccountsView: View {
    @EnvironmentObject var coreDataManager: CoreDataManager
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingNewAccount = false
    @State private var refreshID = UUID() // Para forzar refresh manual si es necesario
    
    // 🔥 USAR @FetchRequest PARA ACTUALIZACIÓN AUTOMÁTICA
    @FetchRequest(
        entity: AccountEntity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \AccountEntity.createdAt, ascending: true)]
    ) var accounts: FetchedResults<AccountEntity>
    
    var totalBalance: Double {
        accounts.reduce(0) { $0 + $1.balance }
    }
    
    var positiveBalance: Double {
        accounts.filter { $0.balance > 0 }.reduce(0) { $0 + $1.balance }
    }
    
    var negativeBalance: Double {
        accounts.filter { $0.balance < 0 }.reduce(0) { $0 + $1.balance }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - Balance Total Card
                    VStack(spacing: 16) {
                        Text("Balance Total")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Text("$\(totalBalance, specifier: "%.2f")")
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .contentTransition(.numericText())
                        
                        // Mini resumen si hay cuentas
                        if !accounts.isEmpty {
                            HStack(spacing: 20) {
                                VStack(spacing: 4) {
                                    Text("Positivo")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("$\(positiveBalance, specifier: "%.2f")")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.green)
                                }
                                
                                if negativeBalance < 0 {
                                    VStack(spacing: 4) {
                                        Text("Negativo")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text("$\(negativeBalance, specifier: "%.2f")")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 28)
                    .padding(.horizontal, 24)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.ultraThinMaterial, lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    
                    // MARK: - Mis Cuentas Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Mis Cuentas")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Spacer()
                            Button(action: {
                                showingNewAccount = true
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "plus")
                                        .font(.caption)
                                    Text("Agregar")
                                        .font(.subheadline)
                                }
                                .foregroundColor(.blue)
                            }
                        }
                        
                        if accounts.isEmpty {
                            // Estado vacío
                            VStack(spacing: 16) {
                                Image(systemName: "creditcard")
                                    .font(.system(size: 40))
                                    .foregroundColor(.secondary)
                                
                                Text("No hay cuentas")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                Text("Agrega tu primera cuenta para comenzar a gestionar tus finanzas")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                
                                Button("Crear primera cuenta") {
                                    showingNewAccount = true
                                }
                                .font(.headline)
                                .foregroundColor(.blue)
                                .padding(.top, 8)
                            }
                            .frame(maxWidth: .infinity, minHeight: 200)
                            .padding(.vertical, 20)
                            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
                        } else {
                            // Grid de cuentas con NavigationLink
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 16) {
                                ForEach(accounts, id: \.id) { accountEntity in
                                    NavigationLink(destination: AccountDetailView(account: accountEntity.toAccount())) {
                                        AccountCardEntityView(accountEntity: accountEntity)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .id(refreshID) // Para forzar refresh si es necesario
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .navigationTitle("Cuentas")
            .navigationBarTitleDisplayMode(.large)
            .background(.ultraThinMaterial)
            .refreshable {
                print("🔄 Manual refresh en AccountsView")
                refreshID = UUID() // Forzar refresh de las tarjetas
            }
        }
        .sheet(isPresented: $showingNewAccount) {
            NewAccountView { newAccount in
                print("✅ Nueva cuenta creada: \(newAccount.name)")
                // Forzar refresh adicional por si acaso
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    refreshID = UUID()
                }
            }
        }
        .onAppear {
            print("🔄 AccountsView apareció con \(accounts.count) cuentas:")
            for account in accounts {
                print("  💳 \(account.name ?? "Sin nombre"): $\(account.balance)")
            }
        }
        .onChange(of: accounts.count) { _, newCount in
            print("📊 AccountsView detectó cambio en número de cuentas: \(newCount)")
            refreshID = UUID() // Forzar refresh cuando cambie el número de cuentas
        }
        .onChange(of: totalBalance) { oldBalance, newBalance in
            print("💰 AccountsView detectó cambio en balance total: $\(oldBalance) → $\(newBalance)")
            for account in accounts {
                print("  💳 \(account.name ?? "Sin nombre"): $\(account.balance)")
            }
            // Forzar refresh cuando cambie el balance total
            refreshID = UUID()
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)) { _ in
            print("🔄 CoreData context saved - forzando refresh de tarjetas")
            refreshID = UUID()
        }
    }
}

// MARK: - ACCOUNT CARD ENTITY VIEW (Trabaja directamente con AccountEntity)
struct AccountCardEntityView: View {
    @ObservedObject var accountEntity: AccountEntity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(accountEntity.colorValue)
                    .frame(width: 36, height: 36)
                    .overlay(
                        Image(systemName: accountEntity.typeIcon)
                            .font(.title3)
                            .foregroundColor(.white)
                    )
                    .shadow(color: accountEntity.colorValue.opacity(0.3), radius: 6, x: 0, y: 3)
                Spacer()
                
                Text(accountEntity.type ?? "Tipo")
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(accountEntity.colorValue.opacity(0.2), in: RoundedRectangle(cornerRadius: 8))
                    .foregroundColor(accountEntity.colorValue)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(accountEntity.name ?? "Sin nombre")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text("$\(accountEntity.balance, specifier: "%.2f")")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(accountEntity.balance >= 0 ? .primary : .red)
                    .contentTransition(.numericText())
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.ultraThinMaterial, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        .onReceive(accountEntity.objectWillChange) { _ in
            print("🔄 AccountCardEntityView detectó cambio en: \(accountEntity.name ?? "Sin nombre") - $\(accountEntity.balance)")
        }
    }
}
