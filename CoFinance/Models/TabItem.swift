// TabItem.swift
// Enumeración para los tabs

import SwiftUI

enum TabItem: CaseIterable {
    case home
    case transactions
    case subscriptions
    case accounts
    
    var title: String {
        switch self {
        case .home: return "Inicio"
        case .transactions: return "Transacciones"
        case .subscriptions: return "Suscripciones"
        case .accounts: return "Cuentas"
        }
    }
    
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .transactions: return "arrow.left.arrow.right.circle.fill"
        case .subscriptions: return "repeat.circle.fill"
        case .accounts: return "creditcard.fill"
        }
    }
}
