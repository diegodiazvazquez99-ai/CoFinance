// Double+Extensions.swift
// Extensiones para Double

import Foundation
import SwiftUI

extension Double {
/// Formatea como moneda con símbolo
var asCurrency: String {
formatted(.currency(code: “MXN”))
}

```
/// Formatea como moneda con código específico
func asCurrency(code: String) -> String {
    formatted(.currency(code: code))
}

/// Formatea como moneda compacta (ej: $1.5K)
var asCompactCurrency: String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "MXN"
    formatter.maximumFractionDigits = 1
    formatter.minimumFractionDigits = 0
    
    if self >= 1000000 {
        return "$\(String(format: "%.1fM", self/1000000))"
    } else if self >= 1000 {
        return "$\(String(format: "%.1fK", self/1000))"
    } else {
        return formatter.string(from: NSNumber(value: self)) ?? "$0"
    }
}

/// Formatea como porcentaje
var asPercentage: String {
    formatted(.percent)
}

/// Formatea como porcentaje con decimales específicos
func asPercentage(decimals: Int) -> String {
    String(format: "%.\(decimals)f%%", self * 100)
}

/// Redondea a N decimales
func rounded(toPlaces places: Int) -> Double {
    let divisor = pow(10.0, Double(places))
    return (self * divisor).rounded() / divisor
}

/// Formatea con separador de miles
var withThousandsSeparator: String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.groupingSeparator = ","
    formatter.locale = Locale(identifier: "es_MX")
    return formatter.string(from: NSNumber(value: self)) ?? "0"
}

/// Convierte a string con formato específico
func formatted(decimals: Int) -> String {
    String(format: "%.\(decimals)f", self)
}

/// Retorna el valor absoluto
var absolute: Double {
    abs(self)
}

/// Verifica si es un número entero
var isWholeNumber: Bool {
    self == rounded()
}

/// Convierte a Int redondeando
var toInt: Int {
    Int(rounded())
}

/// Formatea como cambio positivo/negativo
var asChange: String {
    let sign = self >= 0 ? "+" : ""
    return "\(sign)\(self.asCurrency)"
}

/// Formatea como cambio de porcentaje
var asPercentageChange: String {
    let sign = self >= 0 ? "+" : ""
    return "\(sign)\(self.asPercentage)"
}
```

}