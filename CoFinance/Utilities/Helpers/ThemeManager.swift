// ThemeManager.swift
// Gestor de temas

import SwiftUI
import Combine

class ThemeManager: ObservableObject {
static let shared = ThemeManager()

```
@Published var currentTheme: Theme = LiquidGlassTheme()
@Published var themeMode: ThemeMode = .system
@Published var customAccentColor: Color = .blue
@Published var useSystemAccentColor: Bool = true
@Published var fontScale: CGFloat = 1.0
@Published var useLiquidGlassEffects: Bool = true

enum ThemeMode: String, CaseIterable {
    case light = "Claro"
    case dark = "Oscuro"
    case system = "Sistema"
    case custom = "Personalizado"
    
    var icon: String {
        switch self {
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        case .system: return "circle.lefthalf.filled"
        case .custom: return "paintbrush.fill"
        }
    }
}

enum PresetTheme: String, CaseIterable {
    case liquidGlass = "Liquid Glass"
    case minimal = "Minimalista"
    case neon = "Neón"
    case classic = "Clásico"
    
    var theme: Theme {
        switch self {
        case .liquidGlass: return LiquidGlassTheme()
        case .minimal: return MinimalTheme()
        case .neon: return NeonTheme()
        case .classic: return LightTheme()
        }
    }
    
    var preview: [Color] {
        let theme = self.theme
        return [theme.primaryColor, theme.secondaryColor, theme.accentColor]
    }
}

private var cancellables = Set<AnyCancellable>()

private init() {
    loadThemePreferences()
    observeSystemChanges()
}

// MARK: - Theme Management

/// Aplica un tema predefinido
func applyTheme(_ preset: PresetTheme) {
    withAnimation(.easeInOut(duration: 0.3)) {
        currentTheme = preset.theme
        saveThemePreferences()
    }
    
    // Haptic feedback
    HapticManager.shared.impact(.light)
}

/// Aplica modo de tema
func setThemeMode(_ mode: ThemeMode) {
    themeMode = mode
    
    switch mode {
    case .light:
        currentTheme = LightTheme()
    case .dark:
        currentTheme = DarkTheme()
    case .system:
        applySystemTheme()
    case .custom:
        // Mantener tema actual personalizado
        break
    }
    
    saveThemePreferences()
}

/// Aplica tema del sistema
private func applySystemTheme() {
    let userInterfaceStyle = UITraitCollection.current.userInterfaceStyle
    
    if useLiquidGlassEffects {
        currentTheme = LiquidGlassTheme()
    } else {
        currentTheme = userInterfaceStyle == .dark ? DarkTheme() : LightTheme()
    }
}

/// Observa cambios en el sistema
private func observeSystemChanges() {
    NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
        .sink { [weak self] _ in
            if self?.themeMode == .system {
                self?.applySystemTheme()
            }
        }
        .store(in: &cancellables)
}

// MARK: - Customization

/// Crea un tema personalizado
func createCustomTheme(
    primaryColor: Color,
    secondaryColor: Color,
    accentColor: Color,
    baseTheme: Theme = LightTheme()
) -> CustomTheme {
    return CustomTheme(
        primaryColor: primaryColor,
        secondaryColor: secondaryColor,
        accentColor: accentColor,
        baseTheme: baseTheme
    )
}

/// Actualiza el color de acento
func updateAccentColor(_ color: Color) {
    customAccentColor = color
    useSystemAccentColor = false
    
    // Actualizar tema actual si es personalizado
    if themeMode == .custom {
        if let customTheme = currentTheme as? CustomTheme {
            currentTheme = CustomTheme(
                primaryColor: customTheme.primaryColor,
                secondaryColor: customTheme.secondaryColor,
                accentColor: color,
                baseTheme: customTheme.baseTheme
            )
        }
    }
    
    saveThemePreferences()
}

/// Actualiza la escala de fuente
func updateFontScale(_ scale: CGFloat) {
    fontScale = max(0.8, min(1.5, scale))
    saveThemePreferences()
}

// MARK: - Persistence

/// Guarda preferencias de tema
private func saveThemePreferences() {
    UserDefaults.standard.set(themeMode.rawValue, forKey: "ThemeMode")
    UserDefaults.standard.set(useSystemAccentColor, forKey: "UseSystemAccentColor")
    UserDefaults.standard.set(fontScale, forKey: "FontScale")
    UserDefaults.standard.set(useLiquidGlassEffects, forKey: "UseLiquidGlassEffects")
    
    // Guardar color personalizado como datos
    if let colorData = try? NSKeyedArchiver.archivedData(
        withRootObject: UIColor(customAccentColor),
        requiringSecureCoding: false
    ) {
        UserDefaults.standard.set(colorData, forKey: "CustomAccentColor")
    }
}

/// Carga preferencias de tema
private func loadThemePreferences() {
    if let modeString = UserDefaults.standard.string(forKey: "ThemeMode"),
       let mode = ThemeMode(rawValue: modeString) {
        themeMode = mode
        setThemeMode(mode)
    }
    
    useSystemAccentColor = UserDefaults.standard.bool(forKey: "UseSystemAccentColor")
    fontScale = UserDefaults.standard.double(forKey: "FontScale")
    if fontScale == 0 { fontScale = 1.0 }
    
    useLiquidGlassEffects = UserDefaults.standard.bool(forKey: "UseLiquidGlassEffects")
    
    // Cargar color personalizado
    if let colorData = UserDefaults.standard.data(forKey: "CustomAccentColor"),
       let uiColor = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(colorData) as? UIColor {
        customAccentColor = Color(uiColor)
    }
}

/// Resetea a valores por defecto
func resetToDefaults() {
    themeMode = .system
    currentTheme = LiquidGlassTheme()
    customAccentColor = .blue
    useSystemAccentColor = true
    fontScale = 1.0
    useLiquidGlassEffects = true
    
    saveThemePreferences()
    
    HapticManager.shared.notification(.success)
}
```

}

// MARK: - Custom Theme
struct CustomTheme: Theme {
let primaryColor: Color
let secondaryColor: Color
let accentColor: Color
let baseTheme: Theme

```
var backgroundColor: Color { baseTheme.backgroundColor }
var surfaceColor: Color { baseTheme.surfaceColor }
var cardBackgroundColor: Color { baseTheme.cardBackgroundColor }

var primaryTextColor: Color { baseTheme.primaryTextColor }
var secondaryTextColor: Color { baseTheme.secondaryTextColor }
var disabledTextColor: Color { baseTheme.disabledTextColor }

var successColor: Color { baseTheme.successColor }
var errorColor: Color { baseTheme.errorColor }
var warningColor: Color { baseTheme.warningColor }
var infoColor: Color { baseTheme.infoColor }

var incomeColor: Color { baseTheme.incomeColor }
var expenseColor: Color { baseTheme.expenseColor }
var transferColor: Color { baseTheme.transferColor }
var savingsColor: Color { baseTheme.savingsColor }

var shadowColor: Color { baseTheme.shadowColor }
var shadowRadius: CGFloat { baseTheme.shadowRadius }
var shadowOpacity: Double { baseTheme.shadowOpacity }

var cornerRadius: CGFloat { baseTheme.cornerRadius }
var buttonCornerRadius: CGFloat { baseTheme.buttonCornerRadius }

var spacing: CGFloat { baseTheme.spacing }
var padding: CGFloat { baseTheme.padding }
```

}

// MARK: - Theme Settings View
struct ThemeSettingsView: View {
@StateObject private var themeManager = ThemeManager.shared
@State private var showingColorPicker = false
@State private var selectedColor = Color.blue

```
var body: some View {
    Form {
        Section("Modo de tema") {
            ForEach(ThemeManager.ThemeMode.allCases, id: \.self) { mode in
                Button {
                    themeManager.setThemeMode(mode)
                } label: {
                    HStack {
                        Image(systemName: mode.icon)
                            .frame(width: 30)
                            .foregroundStyle(themeManager.themeMode == mode ? .blue : .secondary)
                        
                        Text(mode.rawValue)
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        
                        if themeManager.themeMode == mode {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.blue)
                        }
                    }
                }
            }
        }
        
        Section("Temas predefinidos") {
            ForEach(ThemeManager.PresetTheme.allCases, id: \.self) { preset in
                Button {
                    themeManager.applyTheme(preset)
                } label: {
                    HStack {
                        // Preview de colores
                        HStack(spacing: 4) {
                            ForEach(preset.preview, id: \.self) { color in
                                Circle()
                                    .fill(color)
                                    .frame(width: 20, height: 20)
                            }
                        }
                        
                        Text(preset.rawValue)
                            .foregroundStyle(.primary)
                        
                        Spacer()
                    }
                }
            }
        }
        
        Section("Personalización") {
            Toggle("Efectos Liquid Glass", isOn: $themeManager.useLiquidGlassEffects)
                .onChange(of: themeManager.useLiquidGlassEffects) { _, _ in
                    themeManager.saveThemePreferences()
                }
            
            Toggle("Color de sistema", isOn: $themeManager.useSystemAccentColor)
            
            if !themeManager.useSystemAccentColor {
                Button {
                    showingColorPicker = true
                } label: {
                    HStack {
                        Text("Color de acento")
                            .foregroundStyle(.primary)
                        Spacer()
                        Circle()
                            .fill(themeManager.customAccentColor)
                            .frame(width: 30, height: 30)
                    }
                }
            }
            
            VStack(alignment: .leading) {
                HStack {
                    Text("Tamaño de texto")
                    Spacer()
                    Text("\(Int(themeManager.fontScale * 100))%")
                        .foregroundStyle(.secondary)
                }
                
                Slider(value: $themeManager.fontScale, in: 0.8...1.5, step: 0.1)
                    .onChange(of: themeManager.fontScale) { _, _ in
                        themeManager.saveThemePreferences()
                    }
            }
        }
        
        Section {
            Button("Restablecer valores por defecto") {
                themeManager.resetToDefaults()
            }
            .foregroundStyle(.red)
        }
    }
    .navigationTitle("Temas")
    .navigationBarTitleDisplayMode(.inline)
    .sheet(isPresented: $showingColorPicker) {
        NavigationStack {
            ColorPicker("Seleccionar color", selection: $selectedColor)
                .padding()
                .navigationTitle("Color de acento")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancelar") {
                            showingColorPicker = false
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Aplicar") {
                            themeManager.updateAccentColor(selectedColor)
                            showingColorPicker = false
                        }
                    }
                }
        }
    }
}
```

}

// MARK: - Font Scale Modifier
struct ScaledFontModifier: ViewModifier {
@StateObject private var themeManager = ThemeManager.shared
let baseSize: CGFloat
let weight: Font.Weight
let design: Font.Design

```
func body(content: Content) -> some View {
    content
        .font(.system(
            size: baseSize * themeManager.fontScale,
            weight: weight,
            design: design
        ))
}
```

}

extension View {
func scaledFont(
size: CGFloat,
weight: Font.Weight = .regular,
design: Font.Design = .default
) -> some View {
modifier(ScaledFontModifier(
baseSize: size,
weight: weight,
design: design
))
}
}