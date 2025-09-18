// TransactionType.swift
// Tipos de transacciones

import SwiftUI

enum TransactionType: String, CaseIterable {
    case income = "income"
    case expense = "expense"
    case transfer = "transfer"
    
    var title: String {
        switch self {
        case .income: return "Ingreso"
        case .expense: return "Gasto"
        case .transfer: return "Transferencia"
        }
    }
    
    var icon: String {
        switch self {
        case .income: return "arrow.down.circle.fill"
        case .expense: return "arrow.up.circle.fill"
        case .transfer: return "arrow.left.arrow.right.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .income: return .green
        case .expense: return .red
        case .transfer: return .blue
        }
    }
}
