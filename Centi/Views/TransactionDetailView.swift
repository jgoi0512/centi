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
                    
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.id) { cat in
                            Text(cat.name).tag(cat.name)
                        }
                    }
                    
                    DatePicker("Date", selection: $selectedDate, displayedComponents: [.date])
                }
                
                Section("Account") {
                    Picker("From Account", selection: $selectedAccount) {
                        Text("Select Account").tag(nil as Account?)
                        ForEach(accounts, id: \.id) { account in
                            Text(account.name).tag(account as Account?)
                        }
                    }
                    
                    if selectedType == .transfer {
                        Picker("To Account", selection: $toAccount) {
                            Text("Select Account").tag(nil as Account?)
                            ForEach(accounts.filter { $0.id != selectedAccount?.id }, id: \.id) { account in
                                Text(account.name).tag(account as Account?)
                            }
                        }
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
            .navigationBarTitleDisplayMode(.automatic)
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
        guard let amountValue = Double(amount), amountValue > 0 else { return }
        
        transaction.amount = amountValue
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
