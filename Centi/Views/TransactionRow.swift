//
//  TransactionRow.swift
//  Centi
//
//  Created by Justin Goi on 4/9/2025.
//

import SwiftUI

struct TransactionRow: View {
    let transaction: Transactions
    
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
                Text(transaction.category)
                    .font(.headline)
                
                if let note = transaction.note {
                    Text(note)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Text(transaction.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("\(transaction.type == .expense ? "-" : "+")\(transaction.amount, specifier: "%.2f")")
                .font(.headline)
                .foregroundColor(colorForTransaction)
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
