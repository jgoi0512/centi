//
//  DashboardView.swift
//  Centi
//
//  Created by Justin Goi on 3/9/2025.
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var accounts: [Account]
    @Query(sort: \Transactions.date, order: .reverse) private var transactions: [Transactions]
    
    private var totalBalance: Double {
        accounts.reduce(0) { $0 + $1.balance }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Total Balance Card
                    TotalBalanceCard(balance: totalBalance)
                        .padding(.horizontal)
                    
                    // Recent Transactions
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Recent Transactions")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        if transactions.isEmpty {
                            EmptyTransactionView()
                                .padding(.horizontal)
                        } else {
                            ForEach(transactions.prefix(10)) { transaction in
                                TransactionRow(transaction: transaction)
                                    .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.bottom, 100)
                }
                .padding(.top)
            }
            .navigationTitle("Dashboard")
            .background(
                LinearGradient(
                    colors: [Color(.systemBackground), Color(.systemGray6)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
    }
}

#Preview {
    DashboardView()
}
