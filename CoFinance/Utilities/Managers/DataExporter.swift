// DataExporter.swift
// Exportador de datos

import Foundation
import SwiftUI
import UniformTypeIdentifiers

class DataExporter: ObservableObject {
static let shared = DataExporter()

```
@Published var isExporting = false
@Published var exportProgress: Double = 0
@Published var lastExportDate: Date?
@Published var lastExportURL: URL?

private init() {}

// MARK: - Exportación CSV

/// Exporta transacciones a CSV
func exportTransactionsToCSV(_ transactions: [Transaction]) -> URL? {
    isExporting = true
    exportProgress = 0
    
    var csvText = "Fecha,Hora,Título,Categoría,Tipo,Monto,Notas,Cuenta\n"
    
    let totalItems = Double(transactions.count)
    
    for (index, transaction) in transactions.enumerated() {
        let date = transaction.date?.formatted(format: "yyyy-MM-dd") ?? ""
        let time = transaction.date?.formatted(format: "HH:mm") ?? ""
        let title = escapeCSV(transaction.title ?? "")
        let category = escapeCSV(transaction.category ?? "")
        let type = transaction.type ?? ""
        let amount = String(format: "%.2f", transaction.amount)
        let notes = escapeCSV(transaction.notes ?? "")
        let account = escapeCSV(transaction.account?.name ?? "")
        
        let row = "\(date),\(time),\(title),\(category),\(type),\(amount),\(notes),\(account)\n"
        csvText.append(row)
        
        exportProgress = Double(index + 1) / totalItems
    }
    
    let fileName = "transacciones_\(Date().formatted(format: "yyyyMMdd_HHmmss")).csv"
    let url = saveToFile(csvText, fileName: fileName)
    
    isExporting = false
    lastExportDate = Date()
    lastExportURL = url
    
    return url
}

/// Exporta suscripciones a CSV
func exportSubscriptionsToCSV(_ subscriptions: [Subscription]) -> URL? {
    isExporting = true
    
    var csvText = "Nombre,Monto,Ciclo,Categoría,Próximo Pago,Estado,Recordatorio\n"
    
    for subscription in subscriptions {
        let name = escapeCSV(subscription.name ?? "")
        let amount = String(format: "%.2f", subscription.amount)
        let cycle = subscription.billingCycle ?? ""
        let category = subscription.category ?? ""
        let nextPayment = subscription.nextPaymentDate?.formatted(format: "yyyy-MM-dd") ?? ""
        let status = subscription.isActive ? "Activa" : "Pausada"
        let reminder = subscription.reminder ? "Sí" : "No"
        
        let row = "\(name),\(amount),\(cycle),\(category),\(nextPayment),\(status),\(reminder)\n"
        csvText.append(row)
    }
    
    let fileName = "suscripciones_\(Date().formatted(format: "yyyyMMdd_HHmmss")).csv"
    let url = saveToFile(csvText, fileName: fileName)
    
    isExporting = false
    lastExportDate = Date()
    lastExportURL = url
    
    return url
}

/// Exporta cuentas a CSV
func exportAccountsToCSV(_ accounts: [Account]) -> URL? {
    var csvText = "Nombre,Tipo,Balance,Moneda,Banco,Número de Cuenta,Última Actualización\n"
    
    for account in accounts {
        let name = escapeCSV(account.name ?? "")
        let type = account.type ?? ""
        let balance = String(format: "%.2f", account.balance)
        let currency = account.currency ?? "MXN"
        let bank = escapeCSV(account.bankName ?? "")
        let accountNumber = account.accountNumber ?? ""
        let lastUpdate = account.lastUpdated?.formatted(format: "yyyy-MM-dd HH:mm") ?? ""
        
        let row = "\(name),\(type),\(balance),\(currency),\(bank),\(accountNumber),\(lastUpdate)\n"
        csvText.append(row)
    }
    
    let fileName = "cuentas_\(Date().formatted(format: "yyyyMMdd_HHmmss")).csv"
    return saveToFile(csvText, fileName: fileName)
}

// MARK: - Exportación JSON

/// Exporta todos los datos a JSON
func exportToJSON(transactions: [Transaction], accounts: [Account], subscriptions: [Subscription]) -> URL? {
    isExporting = true
    exportProgress = 0
    
    var jsonData: [String: Any] = [:]
    
    // Metadata
    jsonData["exportDate"] = ISO8601DateFormatter().string(from: Date())
    jsonData["version"] = "1.0"
    jsonData["appVersion"] = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    
    // Convertir transacciones
    exportProgress = 0.2
    let transactionsData = transactions.map { transaction in
        [
            "id": transaction.id?.uuidString ?? "",
            "title": transaction.title ?? "",
            "amount": transaction.amount,
            "type": transaction.type ?? "",
            "category": transaction.category ?? "",
            "date": ISO8601DateFormatter().string(from: transaction.date ?? Date()),
            "notes": transaction.notes ?? "",
            "accountId": transaction.account?.id?.uuidString ?? ""
        ]
    }
    
    // Convertir cuentas
    exportProgress = 0.5
    let accountsData = accounts.map { account in
        [
            "id": account.id?.uuidString ?? "",
            "name": account.name ?? "",
            "type": account.type ?? "",
            "balance": account.balance,
            "currency": account.currency ?? "MXN",
            "bankName": account.bankName ?? "",
            "accountNumber": account.accountNumber ?? "",
            "lastUpdated": ISO8601DateFormatter().string(from: account.lastUpdated ?? Date())
        ]
    }
    
    // Convertir suscripciones
    exportProgress = 0.8
    let subscriptionsData = subscriptions.map { subscription in
        [
            "id": subscription.id?.uuidString ?? "",
            "name": subscription.name ?? "",
            "amount": subscription.amount,
            "billingCycle": subscription.billingCycle ?? "",
            "category": subscription.category ?? "",
            "startDate": ISO8601DateFormatter().string(from: subscription.startDate ?? Date()),
            "nextPaymentDate": subscription.nextPaymentDate != nil ? ISO8601DateFormatter().string(from: subscription.nextPaymentDate!) : "",
            "isActive": subscription.isActive,
            "reminder": subscription.reminder
        ]
    }
    
    jsonData["transactions"] = transactionsData
    jsonData["accounts"] = accountsData
    jsonData["subscriptions"] = subscriptionsData
    
    // Estadísticas
    jsonData["statistics"] = [
        "totalTransactions": transactions.count,
        "totalAccounts": accounts.count,
        "totalSubscriptions": subscriptions.count,
        "totalBalance": accounts.reduce(0) { $0 + $1.balance }
    ]
    
    do {
        let data = try JSONSerialization.data(withJSONObject: jsonData, options: .prettyPrinted)
        let fileName = "cofinance_backup_\(Date().formatted(format: "yyyyMMdd_HHmmss")).json"
        let url = saveToFile(String(data: data, encoding: .utf8) ?? "", fileName: fileName)
        
        exportProgress = 1.0
        isExporting = false
        lastExportDate = Date()
        lastExportURL = url
        
        return url
    } catch {
        print("Error creating JSON: \(error)")
        isExporting = false
        return nil
    }
}

// MARK: - Importación

/// Importa datos desde JSON
func importFromJSON(url: URL) throws -> (transactions: [[String: Any]], accounts: [[String: Any]], subscriptions: [[String: Any]]) {
    let data = try Data(contentsOf: url)
    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
    
    guard let json = json else {
        throw ExportError.invalidFormat
    }
    
    let transactions = json["transactions"] as? [[String: Any]] ?? []
    let accounts = json["accounts"] as? [[String: Any]] ?? []
    let subscriptions = json["subscriptions"] as? [[String: Any]] ?? []
    
    return (transactions, accounts, subscriptions)
}

// MARK: - Utilidades

/// Escapa caracteres especiales para CSV
private func escapeCSV(_ string: String) -> String {
    if string.contains(",") || string.contains("\"") || string.contains("\n") {
        return "\"\(string.replacingOccurrences(of: "\"", with: "\"\""))\""
    }
    return string
}

/// Guarda contenido en archivo
private func saveToFile(_ content: String, fileName: String) -> URL? {
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let path = documentsPath.appendingPathComponent(fileName)
    
    do {
        try content.write(to: path, atomically: true, encoding: .utf8)
        return path
    } catch {
        print("Error saving file: \(error)")
        return nil
    }
}

/// Genera reporte PDF (básico)
func generatePDFReport(transactions: [Transaction], accounts: [Account]) -> URL? {
    // Implementación básica de PDF
    // Para un PDF más avanzado, usar PDFKit
    
    let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 612, height: 792))
    
    let data = renderer.pdfData { context in
        context.beginPage()
        
        // Título
        let title = "Reporte Financiero - CoFinance"
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 24)
        ]
        title.draw(at: CGPoint(x: 50, y: 50), withAttributes: titleAttributes)
        
        // Fecha
        let date = "Generado: \(Date().formatted(style: .long))"
        let dateAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12)
        ]
        date.draw(at: CGPoint(x: 50, y: 90), withAttributes: dateAttributes)
        
        // Resumen
        var yPosition = 130
        let totalBalance = accounts.reduce(0) { $0 + $1.balance }
        let summary = "Balance Total: \(totalBalance.asCurrency)"
        summary.draw(at: CGPoint(x: 50, y: yPosition), withAttributes: dateAttributes)
        
        // Más contenido puede ser agregado aquí
    }
    
    let fileName = "reporte_\(Date().formatted(format: "yyyyMMdd")).pdf"
    let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let path = documentsPath.appendingPathComponent(fileName)
    
    do {
        try data.write(to: path)
        return path
    } catch {
        print("Error saving PDF: \(error)")
        return nil
    }
}

// MARK: - Error Types

enum ExportError: LocalizedError {
    case invalidFormat
    case saveFailed
    case noData
    
    var errorDescription: String? {
        switch self {
        case .invalidFormat:
            return "El formato del archivo no es válido"
        case .saveFailed:
            return "No se pudo guardar el archivo"
        case .noData:
            return "No hay datos para exportar"
        }
    }
}
```

}