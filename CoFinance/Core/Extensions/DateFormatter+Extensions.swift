import Foundation

// MARK: - DATE FORMATTER EXTENSIONS

extension DateFormatter {
    /// Formateador para mostrar mes y año (ej: "Enero 2024")
    static let monthYear: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "es_ES")
        return formatter
    }()
    
    /// Formateador para fecha corta (ej: "15 Ene")
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        formatter.locale = Locale(identifier: "es_ES")
        return formatter
    }()
    
    /// Formateador para fecha mediana (ej: "15 de enero de 2024")
    static let mediumDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "es_ES")
        return formatter
    }()
}

// MARK: - DATE HELPER EXTENSIONS

extension Date {
    /// Verifica si la fecha es hoy
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    /// Verifica si la fecha es ayer
    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }
    
    /// Calcula los días desde hoy (positivo = en el pasado)
    var daysFromToday: Int {
        Calendar.current.dateComponents([.day], from: self, to: Date()).day ?? 0
    }
    
    /// Devuelve una representación relativa de la fecha (Hoy, Ayer, X días, fecha)
    var relativeString: String {
        if isToday {
            return "Hoy"
        } else if isYesterday {
            return "Ayer"
        } else {
            let days = daysFromToday
            if days <= 7 && days > 0 {
                return "\(days) días"
            } else {
                return DateFormatter.shortDate.string(from: self)
            }
        }
    }
}
