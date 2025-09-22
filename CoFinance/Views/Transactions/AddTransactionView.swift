// AddTransactionView.swift
// Vista para agregar nueva transacción

import SwiftUI

struct AddTransactionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var amount = ""
    @State private var type: TransactionType = .expense
    @State private var category = ""
    @State private var date = Date()
    @State private var notes = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Título", text: $title)
                    
                    HStack {
                        Text("$")
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                    }
                    
                    Picker("Tipo", selection: $type) {
                        ForEach(TransactionType.allCases, id: \.self) { type in
                            Label(type.title, systemImage: type.icon)
                                .tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section {
                    TextField("Categoría", text: $category)
                    
                    DatePicker("Fecha", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    
                    TextField("Notas", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Nueva Transacción")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Guardar") {
                        saveTransaction()
                    }
                    .disabled(title.isEmpty || amount.isEmpty)
                }
            }
        }
    }
    
    private func saveTransaction() {
        let transaction = Transaction(context: viewContext)
        transaction.id = UUID()
        transaction.title = title
        transaction.amount = Double(amount) ?? 0
        transaction.type = type.rawValue
        transaction.category = category.isEmpty ? nil : category
        transaction.date = date
        transaction.notes = notes.isEmpty ? nil : notes
        
        if type == .expense {
            transaction.amount = -abs(transaction.amount)
        }
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Error saving transaction: \(error)")
        }
    }
}
