// Date+Extensions.swift
// Extensiones para Date

import Foundation

extension Date {
/// Retorna el inicio del día
var startOfDay: Date {
Calendar.current.startOfDay(for: self)
}

```
/// Retorna el final del día
var endOfDay: Date {
    var components = DateComponents()
    components.day = 1
    components.second = -1
    return Calendar.current.date(byAdding: components, to: startOfDay) ?? self
}

/// Retorna el inicio del mes
var startOfMonth: Date {
    let components = Calendar.current.dateComponents([.year, .month], from: self)
    return Calendar.current.date(from: components) ?? self
}

/// Retorna el final del mes
var endOfMonth: Date {
    var components = DateComponents()
    components.month = 1
    components.second = -1
    return Calendar.current.date(byAdding: components, to: startOfMonth) ?? self
}

/// Retorna el inicio del año
var startOfYear: Date {
    let components = Calendar.current.dateComponents([.year], from: self)
    return Calendar.current.date(from: components) ?? self
}

/// Retorna el final del año
var endOfYear: Date {
    var components = DateComponents()
    components.year = 1
    components.second = -1
    return Calendar.current.date(byAdding: components, to: startOfYear) ?? self
}

/// Retorna el inicio de la semana
var startOfWeek: Date {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
    return calendar.date(from: components) ?? self
}

/// Formatea la fecha en formato corto
func formatted(style: DateFormatter.Style) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = style
    formatter.locale = Locale(identifier: "es_MX")
    return formatter.string(from: self)
}

/// Formatea la fecha con formato personalizado
func formatted(format: String) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = format
    formatter.locale = Locale(identifier: "es_MX")
    return formatter.string(from: self)
}

/// Retorna true si la fecha es hoy
var isToday: Bool {
    Calendar.current.isDateInToday(self)
}

/// Retorna true si la fecha es ayer
var isYesterday: Bool {
    Calendar.current.isDateInYesterday(self)
}

/// Retorna true si la fecha es mañana
var isTomorrow: Bool {
    Calendar.current.isDateInTomorrow(self)
}

/// Retorna true si la fecha es esta semana
var isThisWeek: Bool {
    Calendar.current.isDate(self, equalTo: Date(), toGranularity: .weekOfYear)
}

/// Retorna true si la fecha es este mes
var isThisMonth: Bool {
    Calendar.current.isDate(self, equalTo: Date(), toGranularity: .month)
}

/// Retorna true si la fecha es este año
var isThisYear: Bool {
    Calendar.current.isDate(self, equalTo: Date(), toGranularity: .year)
}

/// Retorna el número de días desde otra fecha
func days(from date: Date) -> Int {
    Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
}

/// Retorna el número de horas desde otra fecha
func hours(from date: Date) -> Int {
    Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
}

/// Añade días a la fecha
func adding(days: Int) -> Date {
    Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
}

/// Añade meses a la fecha
func adding(months: Int) -> Date {
    Calendar.current.date(byAdding: .month, value: months, to: self) ?? self
}

/// Añade años a la fecha
func adding(years: Int) -> Date {
    Calendar.current.date(byAdding: .year, value: years, to: self) ?? self
}

/// Retorna una representación relativa de la fecha
var relativeString: String {
    let formatter = RelativeDateTimeFormatter()
    formatter.unitsStyle = .full
    formatter.locale = Locale(identifier: "es_MX")
    return formatter.localizedString(for: self, relativeTo: Date())
}

/// Retorna una representación corta relativa
var shortRelativeString: String {
    let formatter = RelativeDateTimeFormatter()
    formatter.unitsStyle = .abbreviated
    formatter.locale = Locale(identifier: "es_MX")
    return formatter.localizedString(for: self, relativeTo: Date())
}
```

}