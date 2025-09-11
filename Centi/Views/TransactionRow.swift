//
//  TransactionRow.swift
//  Centi
//
//  Created by Justin Goi on 4/9/2025.
//

import SwiftUI

struct TransactionRow: View {
    let transaction: Transactions
    @StateObject private var currencyManager = CurrencyManager.shared
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: iconForTransaction)
                .font(.title3)
                .foregroundColor(colorForTransaction)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(colorForTransaction.opacity(0.1))
                )
            
            // Transaction Details
            VStack(alignment: .leading, spacing: 3) {
                // Category and Account
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(transaction.category)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if let account = transaction.account {
                            Text(account.name)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color(account.color).opacity(0.15))
                                .foregroundColor(Color(account.color))
                                .cornerRadius(4)
                        }
                    }
                }
                
                // Note (if exists)
                if let note = transaction.note, !note.isEmpty {
                    Text(note)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                // Time and Transfer info
                HStack(spacing: 4) {
                    Text(transaction.date, style: .time)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if transaction.type == .transfer, let toAccount = transaction.toAccount {
                        Text("→")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(toAccount.name)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Transaction type badge
                    Text(transaction.type.rawValue)
                        .font(.caption2)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(colorForTransaction.opacity(0.1))
                        .foregroundColor(colorForTransaction)
                        .cornerRadius(3)
                }
            }
            
            // Amount
            Text("\(transaction.type == .expense ? "-" : "+")\(currencyManager.formatAmount(transaction.amount, currency: transaction.account?.currency))")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(colorForTransaction)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .cornerRadius(0)
    }
    
    private var iconForTransaction: String {
        switch transaction.type {
        case .income:
            return "arrow.down.circle.fill"
        case .expense:
            return "arrow.up.circle.fill"
        case .transfer:
            return "arrow.left.arrow.right.circle.fill"
        }
    }
    
    private var colorForTransaction: Color {
        switch transaction.type {
        case .income:
            return .green
        case .expense:
            return .red
        case .transfer:
            return .blue
        }
    }
}

#Preview {
//    TransactionRow()
}
