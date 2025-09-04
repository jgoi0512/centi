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
        HStack {
            // Icon
            Image(systemName: iconForTransaction)
                .font(.title3)
                .foregroundColor(colorForTransaction)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(colorForTransaction.opacity(0.1))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(transaction.category)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if let account = transaction.account {
                        Text(account.name)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(account.color).opacity(0.2))
                            .foregroundColor(Color(account.color))
                            .cornerRadius(4)
                    }
                }
                
                if let note = transaction.note, !note.isEmpty {
                    Text(note)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                HStack {
                    Text(transaction.date, style: .time)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if transaction.type == .transfer, let toAccount = transaction.toAccount {
                        Image(systemName: "arrow.right")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Text(toAccount.name)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(transaction.type == .expense ? "-" : "+")\(currencyManager.formatAmount(transaction.amount, currency: transaction.account?.currency))")
                    .font(.headline)
                    .foregroundColor(colorForTransaction)
                
                Text(transaction.type.rawValue)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(.ultraThinMaterial)
        )
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
