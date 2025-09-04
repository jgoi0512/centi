//
//  DashboardTransactionRow.swift
//  Centi
//
//  Created by Justin Goi on 4/9/2025.
//

import SwiftUI

struct DashboardTransactionRow: View {
    let transaction: Transactions
    let onDelete: () -> Void
    @State private var showingDetail = false
    
    var body: some View {
        TransactionRow(transaction: transaction)
            .contentShape(Rectangle())
            .onTapGesture {
                showingDetail = true
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button("Delete") {
                    onDelete()
                }
                .tint(.red)
            }
            .sheet(isPresented: $showingDetail) {
                TransactionDetailView(transaction: transaction)
            }
    }
}