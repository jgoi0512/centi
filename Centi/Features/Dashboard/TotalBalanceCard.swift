//
//  TotalBalanceCard.swift
//  Centi
//
//  Created by Justin Goi on 4/9/2025.
//

import SwiftUI
import SwiftData

struct TotalBalanceCard: View {
    let balance: Double
    let accounts: [Account]
    @Binding var selectedAccounts: Set<String>
    @StateObject private var currencyManager = CurrencyManager.shared
    @State private var showingAccountPicker = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Total Balance")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(currencyManager.formatAmount(balance))
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .contentTransition(.numericText(value: balance))
                .animation(.easeInOut(duration: 0.8), value: balance)
            
            Button(action: {
                showingAccountPicker = true
            }) {
                HStack {
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Text(accountFilterText)
                        .font(.caption)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(25)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.5), Color.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        .sheet(isPresented: $showingAccountPicker) {
            AccountPickerView(
                accounts: accounts,
                selectedAccounts: $selectedAccounts
            )
        }
    }
    
    private var accountFilterText: String {
        if selectedAccounts.isEmpty {
            return "All Accounts"
        } else if selectedAccounts.count == 1 {
            return selectedAccounts.first ?? "All Accounts"
        } else {
            return "\(selectedAccounts.count) Accounts"
        }
    }
}

#Preview {
    @Previewable @State var selectedAccounts: Set<String> = []
    return TotalBalanceCard(
        balance: 0.1,
        accounts: [],
        selectedAccounts: .constant([])
    )
}
