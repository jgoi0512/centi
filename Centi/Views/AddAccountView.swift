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
    
    @State private var accountName = ""
    @State private var accountType: Account.AccountType = .transaction
    @State private var initialBalance = ""
    @State private var selectedIcon = "creditcard"
    @State private var selectedColor = "blue"
    
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
                
                Section("Appearance") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(icons, id: \.self) { icon in
                                Image(systemName: icon)
                                    .font(.title2)
                                    .frame(width: 50, height: 50)
                                    .background(
                                        Circle()
                                            .fill(selectedIcon == icon ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                                    )
                                    .overlay(
                                        Circle()
                                            .stroke(selectedIcon == icon ? Color.blue : Color.clear, lineWidth: 2)
                                    )
                                    .onTapGesture {
                                        selectedIcon = icon
                                    }
                            }
                        }
                        .padding(.vertical)
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(colors, id: \.self) { color in
                                Circle()
                                    .fill(Color(color))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle()
                                            .stroke(selectedColor == color ? Color.primary : Color.clear, lineWidth: 3)
                                    )
                                    .onTapGesture {
                                        selectedColor = color
                                    }
                            }
                        }
                        .padding(.vertical)
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
            color: selectedColor
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
