import SwiftUI

// MARK: - CURRENCY SETTINGS VIEW
struct CurrencySettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.appTheme) private var theme
    
    @State private var searchText = ""
    
    var selectedCurrencyInfo: (name: String, symbol: String, flag: String) {
        CurrencyHelper.currencyInfo(for: settings.preferredCurrency) ?? ("Dólar estadounidense", "$", "🇺🇸")
    }
    
    var filteredCurrencies: [(code: String, name: String, symbol: String, flag: String)] {
        if searchText.isEmpty {
            return CurrencyHelper.supportedCurrencies
        } else {
            return CurrencyHelper.supportedCurrencies.filter { currency in
                currency.name.localizedCaseInsensitiveContains(searchText) ||
                currency.code.localizedCaseInsensitiveContains(searchText) ||
                currency.symbol.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Divisa Actual
            VStack(spacing: 16) {
                Text("Divisa actual")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 16) {
                    Text(selectedCurrencyInfo.flag)
                        .font(.system(size: 40))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(selectedCurrencyInfo.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 8) {
                            Text(settings.preferredCurrency)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("•")
                                .foregroundColor(.secondary)
                            
                            Text(selectedCurrencyInfo.symbol)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(theme.accentColor)
                        }
                    }
                    
                    Spacer()
                }
                
                // Ejemplo de formato
                VStack(spacing: 8) {
                    Text("Ejemplo de formato:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 16) {
                        VStack(spacing: 4) {
                            Text("Positivo")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            Text(settings.formatCurrency(1234.56))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                        }
                        
                        VStack(spacing: 4) {
                            Text("Negativo")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            Text(settings.formatCurrency(1234.56))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: theme.cornerRadius)
                    .fill(.thinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: theme.cornerRadius)
                            .stroke(.ultraThinMaterial, lineWidth: 1)
                    )
            )
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // MARK: - Buscador
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                        .font(.system(size: 16, weight: .medium))
                    
                    TextField("Buscar divisa...", text: $searchText)
                        .textFieldStyle(.plain)
                        .font(.body)
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                searchText = ""
                            }
                        }) {
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
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            
            // MARK: - Lista de Divisas
            List {
                Section {
                    ForEach(filteredCurrencies, id: \.code) { currency in
                        CurrencyRowView(
                            currency: currency,
                            isSelected: currency.code == settings.preferredCurrency,
                            onSelect: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    settings.updateCurrency(
                                        code: currency.code,
                                        symbol: currency.symbol,
                                        name: currency.name
                                    )
                                }
                                
                                // Haptic feedback
                                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                impactFeedback.impactOccurred()
                            }
                        )
                    }
                } header: {
                    Text("Seleccionar divisa (\(filteredCurrencies.count))")
                } footer: {
                    if !searchText.isEmpty && filteredCurrencies.isEmpty {
                        Text("No se encontraron divisas que coincidan con '\(searchText)'")
                    } else {
                        Text("La divisa seleccionada se aplicará a toda la aplicación y afectará cómo se muestran los montos.")
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(.clear)
        }
        .background(.ultraThinMaterial)
        .navigationTitle("Divisa")
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

// MARK: - CURRENCY ROW VIEW
struct CurrencyRowView: View {
    let currency: (code: String, name: String, symbol: String, flag: String)
    let isSelected: Bool
    let onSelect: () -> Void
    @Environment(\.appTheme) private var theme
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                // Bandera
                Text(currency.flag)
                    .font(.system(size: 32))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(currency.name)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    HStack(spacing: 8) {
                        Text(currency.code)
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.secondary.opacity(0.2), in: RoundedRectangle(cornerRadius: 4))
                            .foregroundColor(.secondary)
                        
                        Text(currency.symbol)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(theme.accentColor)
                    }
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(theme.accentColor)
                        .font(.title3)
                        .symbolEffect(.bounce.up, options: .nonRepeating)
                }
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? theme.accentColor.opacity(0.1) : Color.clear)
                .animation(.easeInOut(duration: 0.2), value: isSelected)
        )
    }
}

// MARK: - PREVIEW
#Preview {
    NavigationView {
        CurrencySettingsView()
            .environmentObject(SettingsManager.shared)
            .appTheme(AppTheme())
    }
}
