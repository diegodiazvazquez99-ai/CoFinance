// CurrencyConverter.swift
// Convertidor de divisas

import Foundation
import Combine
import SwiftUI

class CurrencyConverter: ObservableObject {
@Published var exchangeRates: [String: Double] = [:]
@Published var isLoading = false
@Published var lastUpdated: Date?
@Published var errorMessage: String?

```
private var cancellables = Set<AnyCancellable>()

// Singleton
static let shared = CurrencyConverter()

// API Key (deberías obtener una de un servicio como exchangerate-api.com)
private let apiKey = "YOUR_API_KEY_HERE"
private let baseURL = "https://api.exchangerate-api.com/v4/latest/"

/// Tipos de cambio predeterminados (offline)
private let defaultRates: [String: Double] = [
    "USD": 0.059,  // 1 MXN = 0.059 USD aproximadamente
    "EUR": 0.054,  // 1 MXN = 0.054 EUR aproximadamente
    "MXN": 1.0,
    "GBP": 0.047,  // 1 MXN = 0.047 GBP aproximadamente
    "JPY": 8.82,   // 1 MXN = 8.82 JPY aproximadamente
    "CAD": 0.079,  // 1 MXN = 0.079 CAD aproximadamente
    "AUD": 0.089,  // 1 MXN = 0.089 AUD aproximadamente
    "CHF": 0.052,  // 1 MXN = 0.052 CHF aproximadamente
    "CNY": 0.42,   // 1 MXN = 0.42 CNY aproximadamente
]

init() {
    exchangeRates = defaultRates
    loadCachedRates()
}

// MARK: - Conversión

/// Convierte monto entre divisas
func convert(amount: Double, from: String, to: String) -> Double {
    // Si son la misma moneda, no convertir
    if from == to {
        return amount
    }
    
    // Usar tipos de cambio actualizados o predeterminados
    let fromRate = exchangeRates[from] ?? defaultRates[from] ?? 1.0
    let toRate = exchangeRates[to] ?? defaultRates[to] ?? 1.0
    
    // Convertir a MXN primero (base), luego a divisa destino
    let mxnAmount = amount / fromRate
    return mxnAmount * toRate
}

/// Convierte y formatea el monto
func convertFormatted(amount: Double, from: String, to: String) -> String {
    let converted = convert(amount: amount, from: from, to: to)
    return converted.formatted(.currency(code: to))
}

// MARK: - Actualización de tipos de cambio

/// Actualiza tipos de cambio desde API
func updateExchangeRates(baseCurrency: String = "MXN") {
    guard !isLoading else { return }
    
    isLoading = true
    errorMessage = nil
    
    // URL de la API (ejemplo con exchangerate-api)
    let urlString = "\(baseURL)\(baseCurrency)"
    
    guard let url = URL(string: urlString) else {
        errorMessage = "URL inválida"
        isLoading = false
        return
    }
    
    URLSession.shared.dataTaskPublisher(for: url)
        .map(\.data)
        .decode(type: ExchangeRateResponse.self, decoder: JSONDecoder())
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = "Error al actualizar: \(error.localizedDescription)"
                    print("Error actualizando tipos de cambio: \(error)")
                }
            },
            receiveValue: { [weak self] response in
                self?.processExchangeRates(response)
            }
        )
        .store(in: &cancellables)
}

/// Procesa la respuesta de la API
private func processExchangeRates(_ response: ExchangeRateResponse) {
    // Normalizar a MXN como base
    if let mxnRate = response.rates["MXN"] {
        var normalizedRates: [String: Double] = [:]
        
        for (currency, rate) in response.rates {
            normalizedRates[currency] = rate / mxnRate
        }
        
        exchangeRates = normalizedRates
        lastUpdated = Date()
        saveRatesToCache()
    }
}

// MARK: - Cache

/// Guarda tipos de cambio en UserDefaults
private func saveRatesToCache() {
    let encoder = JSONEncoder()
    if let encoded = try? encoder.encode(exchangeRates) {
        UserDefaults.standard.set(encoded, forKey: "CachedExchangeRates")
        UserDefaults.standard.set(lastUpdated, forKey: "ExchangeRatesLastUpdated")
    }
}

/// Carga tipos de cambio del cache
private func loadCachedRates() {
    let decoder = JSONDecoder()
    
    if let data = UserDefaults.standard.data(forKey: "CachedExchangeRates"),
       let cached = try? decoder.decode([String: Double].self, from: data) {
        exchangeRates = cached
    }
    
    lastUpdated = UserDefaults.standard.object(forKey: "ExchangeRatesLastUpdated") as? Date
    
    // Auto-actualizar si han pasado más de 24 horas
    if let lastUpdate = lastUpdated {
        let hoursSinceUpdate = Date().timeIntervalSince(lastUpdate) / 3600
        if hoursSinceUpdate > 24 {
            updateExchangeRates()
        }
    } else {
        // Primera vez, intentar actualizar
        updateExchangeRates()
    }
}

// MARK: - Utilidades

/// Lista de monedas soportadas
var supportedCurrencies: [String] {
    Array(exchangeRates.keys).sorted()
}

/// Símbolo de la moneda
func currencySymbol(for code: String) -> String {
    let locale = NSLocale(localeIdentifier: code)
    return locale.displayName(forKey: .currencySymbol, value: code) ?? code
}

/// Nombre completo de la moneda
func currencyName(for code: String) -> String {
    let locale = Locale.current
    return locale.localizedString(forCurrencyCode: code) ?? code
}

/// Bandera del país para la moneda
func flagEmoji(for currencyCode: String) -> String {
    switch currencyCode {
    case "USD": return "🇺🇸"
    case "EUR": return "🇪🇺"
    case "MXN": return "🇲🇽"
    case "GBP": return "🇬🇧"
    case "JPY": return "🇯🇵"
    case "CAD": return "🇨🇦"
    case "AUD": return "🇦🇺"
    case "CHF": return "🇨🇭"
    case "CNY": return "🇨🇳"
    case "INR": return "🇮🇳"
    case "BRL": return "🇧🇷"
    case "ARS": return "🇦🇷"
    default: return "💱"
    }
}
```

}

// MARK: - Exchange Rate Response Model
struct ExchangeRateResponse: Codable {
let base: String
let date: String?
let rates: [String: Double]
}

// MARK: - Currency Picker View
struct CurrencyPicker: View {
@Binding var selectedCurrency: String
@StateObject private var converter = CurrencyConverter.shared

```
var body: some View {
    Picker("Moneda", selection: $selectedCurrency) {
        ForEach(converter.supportedCurrencies, id: \.self) { currency in
            HStack {
                Text(converter.flagEmoji(for: currency))
                Text(currency)
            }
            .tag(currency)
        }
    }
}
```

}

// MARK: - Currency Conversion View
struct CurrencyConversionView: View {
@State private var amount: String = “”
@State private var fromCurrency = “MXN”
@State private var toCurrency = “USD”
@StateObject private var converter = CurrencyConverter.shared

```
var convertedAmount: Double {
    let value = Double(amount) ?? 0
    return converter.convert(amount: value, from: fromCurrency, to: toCurrency)
}

var body: some View {
    VStack(spacing: 20) {
        // Entrada de cantidad
        VStack(alignment: .leading) {
            Text("Cantidad")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            HStack {
                Text(converter.currencySymbol(for: fromCurrency))
                    .font(.title2)
                
                TextField("0.00", text: $amount)
                    .keyboardType(.decimalPad)
                    .font(.title)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Material.liquidGlass)
            )
        }
        
        // Selector de monedas
        HStack {
            CurrencyPicker(selectedCurrency: $fromCurrency)
                .pickerStyle(.menu)
            
            Button {
                withAnimation {
                    let temp = fromCurrency
                    fromCurrency = toCurrency
                    toCurrency = temp
                }
                HapticManager.shared.impact(.light)
            } label: {
                Image(systemName: "arrow.left.arrow.right")
                    .font(.title3)
                    .foregroundStyle(.blue)
            }
            
            CurrencyPicker(selectedCurrency: $toCurrency)
                .pickerStyle(.menu)
        }
        
        // Resultado
        VStack(alignment: .leading) {
            Text("Resultado")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            HStack {
                Text(converter.currencySymbol(for: toCurrency))
                    .font(.title2)
                
                Text(convertedAmount.formatted(decimals: 2))
                    .font(.title)
                    .contentTransition(.numericText())
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.green.opacity(0.1))
            )
        }
        
        // Última actualización
        if let lastUpdated = converter.lastUpdated {
            Text("Actualizado: \(lastUpdated.relativeString)")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        
        // Botón actualizar
        Button {
            converter.updateExchangeRates()
        } label: {
            Label("Actualizar tipos de cambio", systemImage: "arrow.clockwise")
                .font(.caption)
        }
        .disabled(converter.isLoading)
    }
    .padding()
}
```

}