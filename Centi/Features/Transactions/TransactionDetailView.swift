//
//  TransactionDetailView.swift
//  Centi
//
//  Created by Justin Goi on 4/9/2025.
//

import SwiftUI
import SwiftData

struct TransactionDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var accounts: [Account]
    @Query private var categories: [Category]
    
    let transaction: Transactions
    
    @State private var amount: String
    @State private var selectedType: Transactions.TransactionType
    @State private var category: String
    @State private var note: String
    @State private var selectedDate: Date
    @State private var selectedAccount: Account?
    @State private var toAccount: Account?
    @State private var showingDeleteAlert = false
    
    init(transaction: Transactions) {
        self.transaction = transaction
        _amount = State(initialValue: String(format: "%.2f", transaction.amount))
        _selectedType = State(initialValue: transaction.type)
        _category = State(initialValue: transaction.category)
        _note = State(initialValue: transaction.note ?? "")
        _selectedDate = State(initialValue: transaction.date)
        _selectedAccount = State(initialValue: transaction.account)
        _toAccount = State(initialValue: transaction.toAccount)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Transaction Details") {
                    HStack {
                        Text("Amount")
                        Spacer()
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    Picker("Type", selection: $selectedType) {
                        ForEach(Transactions.TransactionType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.id) { cat in
                            Text(cat.name).tag(cat.name)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    DatePicker("Date", selection: $selectedDate, displayedComponents: [.date])
                }
                
                Section("Account") {
                    Picker("From Account", selection: $selectedAccount) {
                        Text("Select Account").tag(nil as Account?)
                        ForEach(accounts, id: \.id) { account in
                            Text(account.name).tag(account as Account?)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    if selectedType == .transfer {
                        Picker("To Account", selection: $toAccount) {
                            Text("Select Account").tag(nil as Account?)
                            ForEach(accounts.filter { $0.id != selectedAccount?.id }, id: \.id) { account in
                                Text(account.name).tag(account as Account?)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
                
                Section("Additional Info") {
                    TextField("Note (Optional)", text: $note, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section {
                    Button("Delete Transaction") {
                        showingDeleteAlert = true
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Edit Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveTransaction()
                    }
                    .fontWeight(.semibold)
                }
            }
            .alert("Delete Transaction", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteTransaction()
                }
            } message: {
                Text("Are you sure you want to delete this transaction? This action cannot be undone.")
            }
        }
    }
    
    private func saveTransaction() {
        guard let newAmount = Double(amount), newAmount > 0 else { return }
        
        let originalAmount = transaction.amount
        let originalType = transaction.type
        let originalAccount = transaction.account
        let originalToAccount = transaction.toAccount
        
        // Reverse the original transaction's effect on account balances
        if let account = originalAccount {
            switch originalType {
            case .income:
                account.balance -= originalAmount
            case .expense:
                account.balance += originalAmount
            case .transfer:
                account.balance += originalAmount
                if let toAcc = originalToAccount {
                    toAcc.balance -= originalAmount
                    toAcc.modifiedAt = Date()
                }
            }
        }
        
        // Apply the new transaction's effect on account balances
        if let account = selectedAccount {
            switch selectedType {
            case .income:
                account.balance += newAmount
            case .expense:
                account.balance -= newAmount
            case .transfer:
                account.balance -= newAmount
                if let toAcc = toAccount {
                    toAcc.balance += newAmount
                    toAcc.modifiedAt = Date()
                }
            }
            account.modifiedAt = Date()
        }
        
        // Update the transaction properties
        transaction.amount = newAmount
        transaction.type = selectedType
        transaction.category = category
        transaction.note = note.isEmpty ? nil : note
        transaction.date = selectedDate
        transaction.account = selectedAccount
        transaction.toAccount = selectedType == .transfer ? toAccount : nil
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error saving transaction: \(error)")
        }
    }
    
    private func deleteTransaction() {
        // Update account balances before deleting the transaction
        if let account = transaction.account {
            switch transaction.type {
            case .income:
                account.balance -= transaction.amount
            case .expense:
                account.balance += transaction.amount
            case .transfer:
                account.balance += transaction.amount
                if let toAccount = transaction.toAccount {
                    toAccount.balance -= transaction.amount
                    toAccount.modifiedAt = Date()
                }
            }
            account.modifiedAt = Date()
        }
        
        modelContext.delete(transaction)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error deleting transaction: \(error)")
        }
    }
}
