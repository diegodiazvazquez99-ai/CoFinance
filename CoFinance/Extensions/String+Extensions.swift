// String+Extensions.swift
// Extensiones para String

import Foundation

extension String {
// MARK: - Validaciones

```
/// Valida si es un email válido
var isValidEmail: Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailPred.evaluate(with: self)
}

/// Valida si contiene solo números
var isNumeric: Bool {
    return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
}

/// Valida si es un número de teléfono válido (formato mexicano)
var isValidPhoneNumber: Bool {
    let phoneRegex = "^[0-9]{10}$"
    let phonePred = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
    return phonePred.evaluate(with: self.replacingOccurrences(of: " ", with: ""))
}

// MARK: - Formateo

/// Retorna las iniciales del string
var initials: String {
    let words = self.components(separatedBy: " ")
    let initials = words.compactMap { $0.first }.map { String($0) }
    return initials.joined().uppercased().prefix(2).description
}

/// Formatea como número de cuenta (con asteriscos)
var maskedAccountNumber: String {
    guard self.count >= 4 else { return self }
    return "•••• " + self.suffix(4)
}

/// Formatea como número de tarjeta
var maskedCardNumber: String {
    guard self.count >= 16 else { return self }
    let last4 = self.suffix(4)
    return "•••• •••• •••• \(last4)"
}

/// Capitaliza la primera letra
var capitalizedFirst: String {
    return prefix(1).uppercased() + dropFirst()
}

/// Elimina espacios en blanco al inicio y final
var trimmed: String {
    return trimmingCharacters(in: .whitespacesAndNewlines)
}

/// Formatea como moneda desde string
func toCurrency() -> Double? {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = Locale(identifier: "es_MX")
    
    let cleanString = self.replacingOccurrences(of: formatter.currencySymbol, with: "")
        .replacingOccurrences(of: formatter.groupingSeparator, with: "")
        .replacingOccurrences(of: formatter.decimalSeparator, with: ".")
        .trimmed
    
    return Double(cleanString)
}

/// Formatea como número de teléfono
var formattedPhoneNumber: String {
    let cleanNumber = self.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
    
    guard cleanNumber.count == 10 else { return self }
    
    let mask = "XXX XXX XXXX"
    var result = ""
    var index = cleanNumber.startIndex
    
    for ch in mask where index < cleanNumber.endIndex {
        if ch == "X" {
            result.append(cleanNumber[index])
            index = cleanNumber.index(after: index)
        } else {
            result.append(ch)
        }
    }
    
    return result
}

// MARK: - Utilidades

/// Retorna true si el string está vacío o solo contiene espacios
var isBlank: Bool {
    return trimmed.isEmpty
}

/// Cuenta las palabras en el string
var wordCount: Int {
    let words = self.components(separatedBy: .whitespacesAndNewlines)
    return words.filter { !$0.isEmpty }.count
}

/// Convierte a Base64
var base64Encoded: String? {
    return data(using: .utf8)?.base64EncodedString()
}

/// Decodifica desde Base64
var base64Decoded: String? {
    guard let data = Data(base64Encoded: self) else { return nil }
    return String(data: data, encoding: .utf8)
}

/// Retorna el string sin caracteres especiales
var alphanumericOnly: String {
    return self.replacingOccurrences(of: "[^a-zA-Z0-9]", with: "", options: .regularExpression)
}

/// Trunca el string a un largo específico
func truncated(to length: Int, trailing: String = "...") -> String {
    if self.count > length {
        let endIndex = self.index(self.startIndex, offsetBy: length)
        return String(self[..<endIndex]) + trailing
    }
    return self
}

/// Separa un string camelCase
var camelCaseToWords: String {
    return self.unicodeScalars.reduce("") { (result, scalar) in
        if CharacterSet.uppercaseLetters.contains(scalar) {
            return result + " " + String(scalar)
        } else {
            return result + String(scalar)
        }
    }.trimmed.capitalizedFirst
}

/// Subscript seguro para obtener un carácter
subscript(safe index: Int) -> Character? {
    guard index >= 0, index < count else { return nil }
    return self[self.index(self.startIndex, offsetBy: index)]
}
```

}