// HapticManager.swift
// Gestor de haptic feedback

import UIKit
import CoreHaptics

class HapticManager {
static let shared = HapticManager()

```
private var engine: CHHapticEngine?
private var supportsHaptics: Bool = false

private init() {
    checkHapticSupport()
    prepareHaptics()
}

/// Verifica si el dispositivo soporta haptics
private func checkHapticSupport() {
    supportsHaptics = CHHapticEngine.capabilitiesForHardware().supportsHaptics
}

/// Prepara el motor de haptics
private func prepareHaptics() {
    guard supportsHaptics else { return }
    
    do {
        engine = try CHHapticEngine()
        try engine?.start()
        
        // Configurar para reiniciar si se detiene
        engine?.resetHandler = { [weak self] in
            do {
                try self?.engine?.start()
            } catch {
                print("Error al reiniciar el motor de haptics: \(error)")
            }
        }
    } catch {
        print("Error al crear el motor de haptics: \(error)")
    }
}

// MARK: - Haptic Simple

/// Haptic de impacto
func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
    let generator = UIImpactFeedbackGenerator(style: style)
    generator.prepare()
    generator.impactOccurred()
}

/// Haptic de notificación
func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
    let generator = UINotificationFeedbackGenerator()
    generator.prepare()
    generator.notificationOccurred(type)
}

/// Haptic de selección (para cambios pequeños)
func selection() {
    let generator = UISelectionFeedbackGenerator()
    generator.prepare()
    generator.selectionChanged()
}

// MARK: - Haptic Personalizado

/// Haptic para transacción exitosa
func transactionSuccess() {
    guard supportsHaptics else {
        notification(.success)
        return
    }
    
    do {
        let pattern = try createSuccessPattern()
        let player = try engine?.makePlayer(with: pattern)
        try player?.start(atTime: 0)
    } catch {
        // Fallback a haptic simple
        notification(.success)
    }
}

/// Haptic para error
func error() {
    guard supportsHaptics else {
        notification(.error)
        return
    }
    
    do {
        let pattern = try createErrorPattern()
        let player = try engine?.makePlayer(with: pattern)
        try player?.start(atTime: 0)
    } catch {
        notification(.error)
    }
}

/// Haptic para warning
func warning() {
    guard supportsHaptics else {
        notification(.warning)
        return
    }
    
    do {
        let pattern = try createWarningPattern()
        let player = try engine?.makePlayer(with: pattern)
        try player?.start(atTime: 0)
    } catch {
        notification(.warning)
    }
}

/// Haptic suave para hover/preview
func softTouch() {
    guard supportsHaptics else {
        impact(.light)
        return
    }
    
    do {
        let event = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.3),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
            ],
            relativeTime: 0
        )
        
        let pattern = try CHHapticPattern(events: [event], parameters: [])
        let player = try engine?.makePlayer(with: pattern)
        try player?.start(atTime: 0)
    } catch {
        impact(.light)
    }
}

/// Haptic para pull to refresh
func pullToRefresh() {
    guard supportsHaptics else {
        impact(.medium)
        return
    }
    
    do {
        let events = [
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
                ],
                relativeTime: 0
            ),
            CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.4),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.6)
                ],
                relativeTime: 0.1
            )
        ]
        
        let pattern = try CHHapticPattern(events: events, parameters: [])
        let player = try engine?.makePlayer(with: pattern)
        try player?.start(atTime: 0)
    } catch {
        impact(.medium)
    }
}

// MARK: - Patrones Personalizados

private func createSuccessPattern() throws -> CHHapticPattern {
    let events = [
        CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
            ],
            relativeTime: 0
        ),
        CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
            ],
            relativeTime: 0.15
        )
    ]
    
    return try CHHapticPattern(events: events, parameters: [])
}

private func createErrorPattern() throws -> CHHapticPattern {
    let events = [
        CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
            ],
            relativeTime: 0
        ),
        CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
            ],
            relativeTime: 0.1
        ),
        CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.6)
            ],
            relativeTime: 0.2
        )
    ]
    
    return try CHHapticPattern(events: events, parameters: [])
}

private func createWarningPattern() throws -> CHHapticPattern {
    let events = [
        CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.6)
            ],
            relativeTime: 0,
            duration: 0.3
        )
    ]
    
    return try CHHapticPattern(events: events, parameters: [])
}
```

}