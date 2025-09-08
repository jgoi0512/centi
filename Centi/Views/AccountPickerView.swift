//
//  AccountPickerView.swift
//  Centi
//
//  Created by Justin Goi on 6/9/2025.
//

import SwiftUI

struct AccountPickerView: View {
    @Environment(\.dismiss) private var dismiss
    let accounts: [Account]
    @Binding var selectedAccounts: Set<String>
    
    @State private var tempSelectedAccounts: Set<String>
    
    init(accounts: [Account], selectedAccounts: Binding<Set<String>>) {
        self.accounts = accounts
        self._selectedAccounts = selectedAccounts
        self._tempSelectedAccounts = State(initialValue: selectedAccounts.wrappedValue)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Select Accounts") {
                    HStack {
                        Button(tempSelectedAccounts.isEmpty ? "Select All" : "Clear Selection") {
                            if tempSelectedAccounts.isEmpty {
                                tempSelectedAccounts = Set(accounts.map { $0.name })
                            } else {
                                tempSelectedAccounts.removeAll()
                            }
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                        Spacer()
                    }
                    
                    ForEach(accounts, id: \.id) { account in
                        HStack {
                            Image(systemName: tempSelectedAccounts.contains(account.name) ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(tempSelectedAccounts.contains(account.name) ? .blue : .gray)
                            
                            Image(systemName: account.icon)
                                .foregroundColor(Color(account.color))
                            
                            Text(account.name)
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.1)) {
                                if tempSelectedAccounts.contains(account.name) {
                                    tempSelectedAccounts.remove(account.name)
                                } else {
                                    tempSelectedAccounts.insert(account.name)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Filter by Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        selectedAccounts = tempSelectedAccounts
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}