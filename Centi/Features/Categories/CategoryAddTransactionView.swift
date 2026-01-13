//
//  CategoryAddTransactionView.swift
//  Centi
//
//  Created by Justin Goi on 13/1/2026.
//

import SwiftUI
import SwiftData

struct CategoryAddTransactionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var accounts: [Account]
    
    let category: Category
    
    @FocusState private var isAmountFieldFocused: Bool
    @FocusState private var isNoteFieldFocused: Bool
    
    @State private var selectedType: Transactions.TransactionType = .expense
    @State private var amount: String = ""
    @State private var selectedAccount: Account?
    @State private var toAccount: Account?
    @State private var note: String = ""
    @State private var date = Date()
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Image(systemName: category.icon)
                            .foregroundColor(Color(category.color))
                            .frame(width: 30)
                        Text(category.name)
                            .font(.headline)
                    }
                }
                
                Section("Transaction Type") {
                    Picker("Type", selection: $selectedType) {
                        ForEach(Transactions.TransactionType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Amount") {
                    TextField("0.00", text: $amount)
                        .focused($isAmountFieldFocused)
                        .keyboardType(.decimalPad)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .submitLabel(.done)
                        .onSubmit {
                            isAmountFieldFocused = false
                        }
                }
                
                Section("Account") {
                    Picker("Account", selection: $selectedAccount) {
                        Text("Select Account").tag(nil as Account?)
                        ForEach(accounts) { account in
                            Text(account.name).tag(account as Account?)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                if selectedType == .transfer {
                    Section("Transfer To") {
                        Picker("To Account", selection: $toAccount) {
                            Text("Select Account").tag(nil as Account?)
                            ForEach(accounts.filter { $0 != selectedAccount }) { account in
                                Text(account.name).tag(account as Account?)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
                
                Section("Details") {
                    TextField("Note (Optional)", text: $note)
                        .focused($isNoteFieldFocused)
                        .submitLabel(.done)
                        .onSubmit {
                            isNoteFieldFocused = false
                        }
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                        .onTapGesture {
                            isAmountFieldFocused = false
                            isNoteFieldFocused = false
                        }
                }
            }
            .navigationTitle("Add Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .onTapGesture {
                isAmountFieldFocused = false
                isNoteFieldFocused = false
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        isAmountFieldFocused = false
                        isNoteFieldFocused = false
                        saveTransaction()
                    }
                    .disabled(amount.isEmpty || selectedAccount == nil || (selectedType == .transfer && toAccount == nil))
                }
            }
        }
    }
    
    private func saveTransaction() {
        let trimmedAmount = amount.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let amountDouble = Double(trimmedAmount),
              let account = selectedAccount else { return }
        
        let transaction = Transactions(
            amount: amountDouble,
            type: selectedType,
            category: category.name, // Pre-filled from the category passed in
            note: trimmedNote.isEmpty ? nil : trimmedNote,
            date: date,
            account: account,
            toAccount: selectedType == .transfer ? toAccount : nil
        )
        
        withAnimation(.easeInOut(duration: 0.3)) {
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
                    toAcc.modifiedAt = Date()
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
}
