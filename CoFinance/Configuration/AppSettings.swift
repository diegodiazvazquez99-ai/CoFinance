// AppSettings.swift
// Configuración de la app con flags de desarrollo

import Foundation
import Combine

class AppSettings: ObservableObject {
    @Published var enableBiometrics: Bool
    @Published var enableNotifications: Bool
    @Published var enableiCloud: Bool
    @Published var selectedCurrency: String
    @Published var selectedLanguage: String
    @Published var enableHaptics: Bool
    @Published var enableSiri: Bool
    @Published var autoLockTimeout: Int
    @Published var enableFaceID: Bool
    
    // 🚀 NUEVOS FLAGS DE DESARROLLO
    @Published var developmentMode: Bool
    @Published var enablePushNotificationsDev: Bool
    @Published var enableiCloudDev: Bool
    
    // Computed properties que controlan las funciones
    var isPushNotificationsEnabled: Bool {
        #if DEBUG
            return developmentMode ? enablePushNotificationsDev : enableNotifications
        #else
            return enableNotifications
        #endif
    }
    
    var isiCloudEnabled: Bool {
        #if DEBUG
            return developmentMode ? enableiCloudDev : enableiCloud
        #else
            return enableiCloud
        #endif
    }
    
    init() {
        self.enableBiometrics = UserDefaults.standard.bool(forKey: "enableBiometrics")
        self.enableNotifications = UserDefaults.standard.bool(forKey: "enableNotifications")
        self.enableiCloud = UserDefaults.standard.bool(forKey: "enableiCloud")
        self.selectedCurrency = UserDefaults.standard.string(forKey: "selectedCurrency") ?? "MXN"
        self.selectedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage") ?? "es"
        self.enableHaptics = UserDefaults.standard.bool(forKey: "enableHaptics")
        self.enableSiri = UserDefaults.standard.bool(forKey: "enableSiri")
        self.autoLockTimeout = UserDefaults.standard.integer(forKey: "autoLockTimeout")
        self.enableFaceID = UserDefaults.standard.bool(forKey: "enableFaceID")
        
        // 🚀 CONFIGURACIÓN DE DESARROLLO
        #if DEBUG
            self.developmentMode = UserDefaults.standard.bool(forKey: "developmentMode")
            self.enablePushNotificationsDev = UserDefaults.standard.bool(forKey: "enablePushNotificationsDev")
            self.enableiCloudDev = UserDefaults.standard.bool(forKey: "enableiCloudDev")
        #else
            self.developmentMode = false
            self.enablePushNotificationsDev = false
            self.enableiCloudDev = false
        #endif
        
        // Observar cambios y guardar
        setupObservers()
    }
    
    private func setupObservers() {
        $enableBiometrics.sink { UserDefaults.standard.set($0, forKey: "enableBiometrics") }.store(in: &cancellables)
        $enableNotifications.sink { UserDefaults.standard.set($0, forKey: "enableNotifications") }.store(in: &cancellables)
        $enableiCloud.sink { UserDefaults.standard.set($0, forKey: "enableiCloud") }.store(in: &cancellables)
        $selectedCurrency.sink { UserDefaults.standard.set($0, forKey: "selectedCurrency") }.store(in: &cancellables)
        $selectedLanguage.sink { UserDefaults.standard.set($0, forKey: "selectedLanguage") }.store(in: &cancellables)
        $enableHaptics.sink { UserDefaults.standard.set($0, forKey: "enableHaptics") }.store(in: &cancellables)
        $enableSiri.sink { UserDefaults.standard.set($0, forKey: "enableSiri") }.store(in: &cancellables)
        $autoLockTimeout.sink { UserDefaults.standard.set($0, forKey: "autoLockTimeout") }.store(in: &cancellables)
        $enableFaceID.sink { UserDefaults.standard.set($0, forKey: "enableFaceID") }.store(in: &cancellables)
        
        #if DEBUG
        $developmentMode.sink { UserDefaults.standard.set($0, forKey: "developmentMode") }.store(in: &cancellables)
        $enablePushNotificationsDev.sink { UserDefaults.standard.set($0, forKey: "enablePushNotificationsDev") }.store(in: &cancellables)
        $enableiCloudDev.sink { UserDefaults.standard.set($0, forKey: "enableiCloudDev") }.store(in: &cancellables)
        #endif
    }
    
    private var cancellables = Set<AnyCancellable>()
}
