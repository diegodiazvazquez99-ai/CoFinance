import SwiftUI
import Combine

// MARK: - VIEW EXTENSIONS

extension View {
    /// Extensión para validación de entrada numérica
    /// Permite solo números y opcionalmente punto decimal
    func numericOnly(_ text: Binding<String>, includeDecimal: Bool = true) -> some View {
        self.onReceive(Just(text.wrappedValue)) { newValue in
            let allowedCharacters = includeDecimal ? "0123456789." : "0123456789"
            let filtered = newValue.filter { allowedCharacters.contains($0) }
            
            // Evitar múltiples puntos decimales
            if includeDecimal {
                let components = filtered.components(separatedBy: ".")
                if components.count > 2 {
                    let validString = components[0] + "." + components[1...].joined()
                    text.wrappedValue = validString
                    return
                }
            }
            
            if filtered != newValue {
                text.wrappedValue = filtered
            }
        }
    }
}
