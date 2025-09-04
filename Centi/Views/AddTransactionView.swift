//
//  AddTransactionView.swift
//  Centi
//
//  Created by Justin Goi on 3/9/2025.
//

import SwiftUI
import SwiftData

struct AddTransactionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var accounts: [Account]
    
    @State private var selectedType: Transactions.TransactionType = .expense
    @State private var amount: String = ""
    @State private var selectedAccount: Account?
    @State private var toAccount: Account?
    @State private var category: String = ""
    @State private var note: String = ""
    @State private var date = Date()
    
    private let expenseCategories = ["Food", "Transport", "Shopping", "Bills", "Entertainment", "Healthcare", "Education", "Other"]
    private let incomeCategories = ["Salary", "Freelance", "Investment", "Gift", "Refund", "Other"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Transaction Type") {
                    Picker("Type", selection: $selectedType) {
                        ForEach(Transactions.TransactionType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section("Amount") {
                    TextField("0.00", text: $amount)
                        .keyboardType(.decimalPad)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                
                Section("Account") {
                    Picker("Account", selection: $selectedAccount) {
                        Text("Select Account").tag(nil as Account?)
                        ForEach(accounts) { account in
                            Text(account.name).tag(account as Account?)
                        }
                    }
                }
                
                if selectedType == .transfer {
                    Section("Transfer To") {
                        Picker("To Account", selection: $toAccount) {
                            Text("Select Account").tag(nil as Account?)
                            ForEach(accounts.filter { $0 != selectedAccount }) { account in
                                Text(account.name).tag(account as Account?)
                            }
                        }
                    }
                }
                
                Section("Category") {
                    Picker("Category", selection: $category) {
                        Text("Select Category").tag("")
                        ForEach(selectedType == .expense ? expenseCategories : incomeCategories, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                }
                
                Section("Details") {
                    TextField("Note (Optional)", text: $note)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
            }
            .navigationTitle("Add Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveTransaction()
                    }
                    .disabled(amount.isEmpty || selectedAccount == nil || (selectedType == .transfer && toAccount == nil))
                }
            }
        }
    }
    
    private func saveTransaction() {
        guard let amountDouble = Double(amount),
              let account = selectedAccount else { return }
        
        let transaction = Transactions(
            amount: amountDouble,
            type: selectedType,
            category: category.isEmpty ? selectedType.rawValue : category,
            note: note.isEmpty ? nil : note,
            date: date,
            account: account,
            toAccount: selectedType == .transfer ? toAccount : nil
        )
        
        modelContext.insert(transaction)
        
        // Update account balances
        switch selectedType {
        case .income:
            account.balance += amountDouble
        case .expense:
            account.balance -= amountDouble
        case .transfer:
            if let toAcc = toAccount {
                account.balance -= amountDouble
                toAcc.balance += amountDouble
            }
        }
        
        account.modifiedAt = Date()
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error saving transaction: \(error)")
        }
    }
}

#Preview {
    AddTransactionView()
}
