// AddAccountView.swift
// Vista para agregar nueva cuenta

import SwiftUI

struct AddAccountView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var type = "Débito"
    @State private var balance = ""
    @State private var accountNumber = ""
    @State private var bankName = ""
    @State private var currency = "MXN"
    
    let accountTypes = ["Débito", "Crédito", "Ahorros", "Inversión"]
    let currencies = ["MXN", "USD", "EUR"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Información de la cuenta") {
                    TextField("Nombre de la cuenta", text: $name)
                    
                    Picker("Tipo de cuenta", selection: $type) {
                        ForEach(accountTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    
                    TextField("Banco", text: $bankName)
                }
                
                Section("Detalles financieros") {
                    HStack {
                        Text("$")
                        TextField("0.00", text: $balance)
                            .keyboardType(.decimalPad)
                    }
                    
                    Picker("Moneda", selection: $currency) {
                        ForEach(currencies, id: \.self) { currency in
                            Text(currency).tag(currency)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    TextField("Últimos 4 dígitos", text: $accountNumber)
                        .keyboardType(.numberPad)
                        .onChange(of: accountNumber) { _, newValue in
                            if newValue.count > 4 {
                                accountNumber = String(newValue.prefix(4))
                            }
                        }
                }
            }
            .navigationTitle("Nueva Cuenta")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Guardar") {
                        saveAccount()
                    }
                    .disabled(name.isEmpty || balance.isEmpty)
                }
            }
        }
    }
    
    private func saveAccount() {
        let account = Account(context: viewContext)
        account.id = UUID()
        account.name = name
        account.type = type
        account.balance = Double(balance) ?? 0
        account.accountNumber = accountNumber.isEmpty ? nil : accountNumber
        account.bankName = bankName.isEmpty ? nil : bankName
        account.currency = currency
        account.lastUpdated = Date()
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Error saving account: \(error)")
        }
    }
}
