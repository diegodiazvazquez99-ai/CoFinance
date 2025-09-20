// Theme.swift
// Sistema de temas

import SwiftUI

// MARK: - Theme Protocol
protocol Theme {
// Colores principales
var primaryColor: Color { get }
var secondaryColor: Color { get }
var accentColor: Color { get }

```
// Colores de fondo
var backgroundColor: Color { get }
var surfaceColor: Color { get }
var cardBackgroundColor: Color { get }

// Colores de texto
var primaryTextColor: Color { get }
var secondaryTextColor: Color { get }
var disabledTextColor: Color { get }

// Colores de estado
var successColor: Color { get }
var errorColor: Color { get }
var warningColor: Color { get }
var infoColor: Color { get }

// Colores financieros
var incomeColor: Color { get }
var expenseColor: Color { get }
var transferColor: Color { get }
var savingsColor: Color { get }

// Sombras
var shadowColor: Color { get }
var shadowRadius: CGFloat { get }
var shadowOpacity: Double { get }

// Esquinas
var cornerRadius: CGFloat { get }
var buttonCornerRadius: CGFloat { get }

// Espaciado
var spacing: CGFloat { get }
var padding: CGFloat { get }
```

}

// MARK: - Light Theme
struct LightTheme: Theme {
let primaryColor = Color.blue
let secondaryColor = Color.purple
let accentColor = Color.orange

```
let backgroundColor = Color(UIColor.systemBackground)
let surfaceColor = Color(UIColor.secondarySystemBackground)
let cardBackgroundColor = Color.white

let primaryTextColor = Color.primary
let secondaryTextColor = Color.secondary
let disabledTextColor = Color.gray

let successColor = Color.green
let errorColor = Color.red
let warningColor = Color.orange
let infoColor = Color.blue

let incomeColor = Color(red: 0.2, green: 0.8, blue: 0.4)
let expenseColor = Color(red: 0.9, green: 0.3, blue: 0.3)
let transferColor = Color(red: 0.3, green: 0.5, blue: 0.9)
let savingsColor = Color(red: 1.0, green: 0.8, blue: 0.2)

let shadowColor = Color.black
let shadowRadius: CGFloat = 10
let shadowOpacity: Double = 0.1

let cornerRadius: CGFloat = 16
let buttonCornerRadius: CGFloat = 12

let spacing: CGFloat = 16
let padding: CGFloat = 20
```

}

// MARK: - Dark Theme
struct DarkTheme: Theme {
let primaryColor = Color.blue
let secondaryColor = Color.purple
let accentColor = Color.orange

```
let backgroundColor = Color(UIColor.systemBackground)
let surfaceColor = Color(UIColor.secondarySystemBackground)
let cardBackgroundColor = Color(UIColor.tertiarySystemBackground)

let primaryTextColor = Color.primary
let secondaryTextColor = Color.secondary
let disabledTextColor = Color.gray

let successColor = Color.green
let errorColor = Color.red
let warningColor = Color.orange
let infoColor = Color.blue

let incomeColor = Color(red: 0.3, green: 0.85, blue: 0.5)
let expenseColor = Color(red: 0.95, green: 0.4, blue: 0.4)
let transferColor = Color(red: 0.4, green: 0.6, blue: 1.0)
let savingsColor = Color(red: 1.0, green: 0.85, blue: 0.3)

let shadowColor = Color.black
let shadowRadius: CGFloat = 10
let shadowOpacity: Double = 0.3

let cornerRadius: CGFloat = 16
let buttonCornerRadius: CGFloat = 12

let spacing: CGFloat = 16
let padding: CGFloat = 20
```

}

// MARK: - Liquid Glass Theme
struct LiquidGlassTheme: Theme {
let primaryColor = Color(red: 0.0, green: 0.5, blue: 1.0)
let secondaryColor = Color(red: 0.6, green: 0.2, blue: 0.9)
let accentColor = Color(red: 1.0, green: 0.6, blue: 0.0)

```
let backgroundColor = Color.clear // Para transparencia
let surfaceColor = Color.white.opacity(0.05)
let cardBackgroundColor = Color.white.opacity(0.1)

let primaryTextColor = Color.primary
let secondaryTextColor = Color.secondary.opacity(0.8)
let disabledTextColor = Color.gray.opacity(0.5)

let successColor = Color(red: 0.2, green: 0.9, blue: 0.4)
let errorColor = Color(red: 1.0, green: 0.3, blue: 0.3)
let warningColor = Color(red: 1.0, green: 0.7, blue: 0.0)
let infoColor = Color(red: 0.0, green: 0.6, blue: 1.0)

let incomeColor = Color(red: 0.2, green: 0.9, blue: 0.5)
let expenseColor = Color(red: 1.0, green: 0.35, blue: 0.35)
let transferColor = Color(red: 0.3, green: 0.6, blue: 1.0)
let savingsColor = Color(red: 1.0, green: 0.85, blue: 0.2)

let shadowColor = Color.black
let shadowRadius: CGFloat = 15
let shadowOpacity: Double = 0.2

let cornerRadius: CGFloat = 20
let buttonCornerRadius: CGFloat = 14

let spacing: CGFloat = 20
let padding: CGFloat = 24
```

}

// MARK: - Custom Themes
struct MinimalTheme: Theme {
let primaryColor = Color.black
let secondaryColor = Color.gray
let accentColor = Color.blue

```
let backgroundColor = Color.white
let surfaceColor = Color(UIColor.systemGray6)
let cardBackgroundColor = Color.white

let primaryTextColor = Color.black
let secondaryTextColor = Color.gray
let disabledTextColor = Color.gray.opacity(0.5)

let successColor = Color.green
let errorColor = Color.red
let warningColor = Color.orange
let infoColor = Color.blue

let incomeColor = Color.green
let expenseColor = Color.red
let transferColor = Color.blue
let savingsColor = Color.orange

let shadowColor = Color.gray
let shadowRadius: CGFloat = 5
let shadowOpacity: Double = 0.05

let cornerRadius: CGFloat = 8
let buttonCornerRadius: CGFloat = 6

let spacing: CGFloat = 12
let padding: CGFloat = 16
```

}

struct NeonTheme: Theme {
let primaryColor = Color(red: 0.0, green: 1.0, blue: 0.8)
let secondaryColor = Color(red: 1.0, green: 0.0, blue: 0.8)
let accentColor = Color(red: 1.0, green: 1.0, blue: 0.0)

```
let backgroundColor = Color.black
let surfaceColor = Color(white: 0.1)
let cardBackgroundColor = Color(white: 0.15)

let primaryTextColor = Color.white
let secondaryTextColor = Color(white: 0.7)
let disabledTextColor = Color(white: 0.4)

let successColor = Color(red: 0.0, green: 1.0, blue: 0.4)
let errorColor = Color(red: 1.0, green: 0.2, blue: 0.4)
let warningColor = Color(red: 1.0, green: 0.8, blue: 0.0)
let infoColor = Color(red: 0.0, green: 0.8, blue: 1.0)

let incomeColor = Color(red: 0.0, green: 1.0, blue: 0.5)
let expenseColor = Color(red: 1.0, green: 0.2, blue: 0.5)
let transferColor = Color(red: 0.2, green: 0.8, blue: 1.0)
let savingsColor = Color(red: 1.0, green: 1.0, blue: 0.0)

let shadowColor = Color(red: 0.0, green: 1.0, blue: 0.8)
let shadowRadius: CGFloat = 20
let shadowOpacity: Double = 0.5

let cornerRadius: CGFloat = 24
let buttonCornerRadius: CGFloat = 16

let spacing: CGFloat = 24
let padding: CGFloat = 28
```

}

// MARK: - Theme Environment Key
struct ThemeEnvironmentKey: EnvironmentKey {
static let defaultValue: Theme = LiquidGlassTheme()
}

extension EnvironmentValues {
var theme: Theme {
get { self[ThemeEnvironmentKey.self] }
set { self[ThemeEnvironmentKey.self] = newValue }
}
}

// MARK: - Theme View Modifier
struct ThemedViewModifier: ViewModifier {
@Environment(.theme) var theme

```
func body(content: Content) -> some View {
    content
        .tint(theme.accentColor)
}
```

}

extension View {
func themed() -> some View {
modifier(ThemedViewModifier())
}
}

// MARK: - Themed Components
struct ThemedButton: View {
let title: String
let action: () -> Void
let style: ButtonStyle
@Environment(.theme) var theme

```
enum ButtonStyle {
    case primary
    case secondary
    case destructive
    case ghost
}

var backgroundColor: Color {
    switch style {
    case .primary:
        return theme.primaryColor
    case .secondary:
        return theme.secondaryColor
    case .destructive:
        return theme.errorColor
    case .ghost:
        return Color.clear
    }
}

var foregroundColor: Color {
    switch style {
    case .primary, .secondary, .destructive:
        return .white
    case .ghost:
        return theme.primaryColor
    }
}

var body: some View {
    Button(action: action) {
        Text(title)
            .font(.headline)
            .foregroundStyle(foregroundColor)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: theme.buttonCornerRadius)
                    .fill(backgroundColor)
            )
    }
    .buttonStyle(.plain)
}
```

}

struct ThemedCard<Content: View>: View {
let content: Content
@Environment(.theme) var theme

```
init(@ViewBuilder content: () -> Content) {
    self.content = content()
}

var body: some View {
    content
        .padding(theme.padding)
        .background(
            RoundedRectangle(cornerRadius: theme.cornerRadius)
                .fill(theme.cardBackgroundColor)
                .shadow(
                    color: theme.shadowColor.opacity(theme.shadowOpacity),
                    radius: theme.shadowRadius,
                    x: 0,
                    y: 4
                )
        )
}
```

}

// MARK: - Theme Preview
struct ThemePreview: View {
let theme: Theme

```
var body: some View {
    VStack(spacing: 20) {
        // Colores principales
        HStack(spacing: 10) {
            ColorSwatch(color: theme.primaryColor, label: "Primary")
            ColorSwatch(color: theme.secondaryColor, label: "Secondary")
            ColorSwatch(color: theme.accentColor, label: "Accent")
        }
        
        // Colores de estado
        HStack(spacing: 10) {
            ColorSwatch(color: theme.successColor, label: "Success")
            ColorSwatch(color: theme.errorColor, label: "Error")
            ColorSwatch(color: theme.warningColor, label: "Warning")
            ColorSwatch(color: theme.infoColor, label: "Info")
        }
        
        // Colores financieros
        HStack(spacing: 10) {
            ColorSwatch(color: theme.incomeColor, label: "Income")
            ColorSwatch(color: theme.expenseColor, label: "Expense")
            ColorSwatch(color: theme.transferColor, label: "Transfer")
            ColorSwatch(color: theme.savingsColor, label: "Savings")
        }
        
        // Ejemplo de tarjeta
        ThemedCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("Tarjeta de ejemplo")
                    .font(.headline)
                    .foregroundStyle(theme.primaryTextColor)
                Text("Este es un texto secundario")
                    .font(.subheadline)
                    .foregroundStyle(theme.secondaryTextColor)
            }
        }
        
        // Botones
        VStack(spacing: 10) {
            ThemedButton(title: "Botón Primario", action: {}, style: .primary)
            ThemedButton(title: "Botón Secundario", action: {}, style: .secondary)
            ThemedButton(title: "Botón Destructivo", action: {}, style: .destructive)
            ThemedButton(title: "Botón Ghost", action: {}, style: .ghost)
        }
    }
    .padding()
    .background(theme.backgroundColor)
    .environment(\.theme, theme)
}
```

}

struct ColorSwatch: View {
let color: Color
let label: String

```
var body: some View {
    VStack(spacing: 4) {
        RoundedRectangle(cornerRadius: 8)
            .fill(color)
            .frame(height: 50)
        Text(label)
            .font(.caption2)
            .foregroundStyle(.secondary)
    }
}
```

}