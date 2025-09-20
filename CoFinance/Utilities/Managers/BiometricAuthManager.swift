// BiometricAuthManager.swift
// Gestor de autenticación biométrica

import LocalAuthentication
import SwiftUI

class BiometricAuthManager: ObservableObject {
@Published var isUnlocked = false
@Published var biometricType: LABiometryType = .none
@Published var isAvailable = false
@Published var errorMessage: String?

```
init() {
    checkBiometricAvailability()
}

/// Verifica disponibilidad de biometría
func checkBiometricAvailability() {
    let context = LAContext()
    var error: NSError?
    
    isAvailable = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    
    if isAvailable {
        biometricType = context.biometryType
    } else if let error = error {
        handleError(error)
    }
}

/// Solicita autenticación biométrica
func authenticate(reason: String = "Accede a tu información financiera de forma segura") {
    let context = LAContext()
    var error: NSError?
    
    // Personalizar mensajes
    context.localizedCancelTitle = "Cancelar"
    context.localizedFallbackTitle = "Usar contraseña"
    
    if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, authError in
            DispatchQueue.main.async {
                if success {
                    self?.isUnlocked = true
                    self?.errorMessage = nil
                    
                    // Haptic feedback de éxito
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                } else if let authError = authError as NSError? {
                    self?.handleError(authError)
                }
            }
        }
    } else {
        // Fallback a passcode/password
        authenticateWithPasscode(reason: reason)
    }
}

/// Autenticación con passcode como fallback
private func authenticateWithPasscode(reason: String) {
    let context = LAContext()
    
    context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { [weak self] success, error in
        DispatchQueue.main.async {
            if success {
                self?.isUnlocked = true
                self?.errorMessage = nil
            } else if let error = error as NSError? {
                self?.handleError(error)
            }
        }
    }
}

/// Maneja errores de autenticación
private func handleError(_ error: NSError) {
    switch error.code {
    case LAError.authenticationFailed.rawValue:
        errorMessage = "Autenticación fallida. Por favor, intenta de nuevo."
        
    case LAError.userCancel.rawValue:
        errorMessage = "Autenticación cancelada"
        
    case LAError.userFallback.rawValue:
        // Usuario eligió usar contraseña
        authenticateWithPasscode(reason: "Ingresa tu contraseña para continuar")
        
    case LAError.biometryNotAvailable.rawValue:
        errorMessage = "La autenticación biométrica no está disponible"
        isAvailable = false
        
    case LAError.biometryNotEnrolled.rawValue:
        errorMessage = "No hay datos biométricos registrados. Configúralos en Ajustes."
        isAvailable = false
        
    case LAError.biometryLockout.rawValue:
        errorMessage = "Demasiados intentos fallidos. Por favor, usa tu contraseña."
        authenticateWithPasscode(reason: "Ingresa tu contraseña para desbloquear")
        
    default:
        errorMessage = "Error de autenticación: \(error.localizedDescription)"
    }
}

/// Bloquea la aplicación
func lock() {
    isUnlocked = false
    errorMessage = nil
}

/// Retorna el nombre del tipo de biometría disponible
var biometricTypeDescription: String {
    switch biometricType {
    case .faceID:
        return "Face ID"
    case .touchID:
        return "Touch ID"
    case .opticID:
        return "Optic ID"
    case .none:
        return "No disponible"
    @unknown default:
        return "Desconocido"
    }
}

/// Retorna el ícono para el tipo de biometría
var biometricIcon: String {
    switch biometricType {
    case .faceID:
        return "faceid"
    case .touchID:
        return "touchid"
    case .opticID:
        return "opticid"
    case .none:
        return "lock.fill"
    @unknown default:
        return "lock.fill"
    }
}
```

}