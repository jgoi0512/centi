//
//  AddAccountView.swift
//  Centi
//
//  Created by Justin Goi on 4/9/2025.
//

import SwiftUI
import SwiftData

struct AddAccountView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var currencyManager = CurrencyManager.shared
    
    @State private var accountName = ""
    @State private var accountType: Account.AccountType = .transaction
    @State private var initialBalance = ""
    @State private var selectedIcon = "creditcard"
    @State private var selectedColor = "blue"
    @State private var selectedCurrency: String? = nil
    
    private let icons = ["creditcard", "banknote", "dollarsign.circle", "building.columns", "chart.line.uptrend.xyaxis"]
    private let colors = ["blue", "green", "purple", "orange", "red", "pink", "yellow"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Account Details") {
                    TextField("Account Name", text: $accountName)
                    
                    Picker("Account Type", selection: $accountType) {
                        ForEach(Account.AccountType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    TextField("Initial Balance", text: $initialBalance)
                        .keyboardType(.decimalPad)
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
                    .pickerStyle(MenuPickerStyle())
                    
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
                                        selectedIcon = icon
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
                                        selectedColor = color
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Add Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveAccount()
                    }
                    .disabled(accountName.isEmpty)
                }
            }
        }
    }
    
    private func saveAccount() {
        let balance = Double(initialBalance) ?? 0
        let account = Account(
            name: accountName,
            type: accountType,
            balance: balance,
            icon: selectedIcon,
            color: selectedColor,
            currency: selectedCurrency
        )
        
        modelContext.insert(account)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error saving account: \(error)")
        }
    }
}

#Preview {
    AddAccountView()
}
