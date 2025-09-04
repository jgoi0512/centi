//
//  TotalBalanceCard.swift
//  Centi
//
//  Created by Justin Goi on 4/9/2025.
//

import SwiftUI

struct TotalBalanceCard: View {
    let balance: Double
    @StateObject private var currencyManager = CurrencyManager.shared
    
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
            
            HStack {
                Label("All Accounts", systemImage: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.green)
            }
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
    }
}

#Preview {
    TotalBalanceCard(balance: 0.1)
}
