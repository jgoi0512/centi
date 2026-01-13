//
//  AccountDetailView.swift
//  Centi
//
//  Created by Justin Goi on 4/9/2025.
//

import SwiftUI
import SwiftData

struct AccountDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var currencyManager = CurrencyManager.shared
    @FocusState private var isNameFieldFocused: Bool
    @FocusState private var isBalanceFieldFocused: Bool
    
    let account: Account
    
    @State private var name: String
    @State private var selectedType: Account.AccountType
    @State private var currentBalance: String
    @State private var selectedIcon: String
    @State private var selectedColor: String
    @State private var selectedCurrency: String?
    
    @State private var showingDeleteAlert = false
    
    private let icons = ["creditcard", "banknote", "dollarsign.circle", "building.columns", "chart.line.uptrend.xyaxis"]
    private let colors = ["appBlue", "appGreen", "appPurple", "appOrange", "appRed", "appPink", "appYellow", "appTeal", "appMint"]
    
    init(account: Account) {
        self.account = account
        _name = State(initialValue: account.name)
        _selectedType = State(initialValue: account.type)
        _currentBalance = State(initialValue: String(format: "%.2f", account.balance))
        _selectedIcon = State(initialValue: account.icon)
        _selectedColor = State(initialValue: account.color)
        _selectedCurrency = State(initialValue: account.currency)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Account Details") {
                    TextField("Account Name", text: $name)
                        .focused($isNameFieldFocused)
                        .submitLabel(.done)
                        .onSubmit {
                            isNameFieldFocused = false
                        }
                    
                    Picker("Account Type", selection: $selectedType) {
                        ForEach(Account.AccountType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.navigationLink)
                    
                    HStack {
                        Text("Current Balance")
                        Spacer()
                        TextField("0.00", text: $currentBalance)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .focused($isBalanceFieldFocused)
                    }
                }
                
                Section("Currency") {
                    Picker("Currency", selection: $selectedCurrency) {
                        Text("Use Default (\(currencyManager.defaultCurrency))").tag(nil as String?)
                        
                        ForEach(Array(CurrencyManager.currencies.keys.sorted()), id: \.self) { code in
                            HStack {
                                Text("\(code) (\(CurrencyManager.currencies[code]?.0 ?? "$"))")
                            }
                            .tag(code as String?)
                        }
                    }
                    .pickerStyle(.navigationLink)
                    
                    Text("If no currency is selected, the default currency from settings will be used.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section("Appearance") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(icons, id: \.self) { icon in
                                Image(systemName: icon)
                                    .font(.title2)
                                    .foregroundColor(selectedIcon == icon ? .blue : .primary)
                                    .frame(width: 50, height: 50)
                                    .background(
                                        Circle()
                                            .fill(selectedIcon == icon ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                                    )
                                    .overlay(
                                        Circle()
                                            .stroke(selectedIcon == icon ? Color.blue : Color.clear, lineWidth: 2)
                                    )
                                    .scaleEffect(selectedIcon == icon ? 1.05 : 1.0)
                                    .animation(.easeInOut(duration: 0.2), value: selectedIcon)
                                    .onTapGesture {
                                        isNameFieldFocused = false
                                        isBalanceFieldFocused = false
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            selectedIcon = icon
                                        }
                                    }
                            }
                        }
                        .padding()
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(colors, id: \.self) { color in
                                Circle()
                                    .fill(Color(color))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle()
                                            .stroke(selectedColor == color ? Color.primary : Color.clear, lineWidth: 2)
                                    )
                                    .scaleEffect(selectedColor == color ? 1.1 : 1.0)
                                    .animation(.easeInOut(duration: 0.2), value: selectedColor)
                                    .onTapGesture {
                                        isNameFieldFocused = false
                                        isBalanceFieldFocused = false
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            selectedColor = color
                                        }
                                    }
                            }
                        }
                        .padding()
                    }
                }
                
                Section("Account Info") {
                    HStack {
                        Text("Created")
                        Spacer()
                        Text(account.createdAt, style: .date)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Last Modified")
                        Spacer()
                        Text(account.modifiedAt, style: .date)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Total Transactions")
                        Spacer()
                        Text("\(account.transactions?.count ?? 0)")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section {
                    Button("Delete Account") {
                        showingDeleteAlert = true
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Account Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        isNameFieldFocused = false
                        isBalanceFieldFocused = false
                        saveAccount()
                    }
                    .fontWeight(.semibold)
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .alert("Delete Account", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteAccount()
                }
            } message: {
                Text("Are you sure you want to delete this account? This will also delete all associated transactions. This action cannot be undone.")
            }
        }
    }
    
    private func saveAccount() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let balanceValue = Double(currentBalance) ?? account.balance
        
        guard !trimmedName.isEmpty else { return }
        
        account.name = trimmedName
        account.type = selectedType
        account.balance = balanceValue
        account.icon = selectedIcon
        account.color = selectedColor
        account.currency = selectedCurrency
        account.modifiedAt = Date()
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error saving account: \(error)")
        }
    }
    
    private func deleteAccount() {
        modelContext.delete(account)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error deleting account: \(error)")
        }
    }
}
