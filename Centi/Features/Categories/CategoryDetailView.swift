//
//  CategoryDetailView.swift
//  Centi
//
//  Created by Justin Goi on 13/1/2026.
//

import SwiftUI
import SwiftData

struct CategoryDetailView: View {
    let category: Category
    let transactions: [Transactions]
    let dateRangeTitle: String
    
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddTransaction = false
    @State private var selectedTransaction: Transactions?
    @State private var transactionToDelete: Transactions?
    @State private var showingDeleteAlert = false
    
    // Sort transactions by date descending
    var sortedTransactions: [Transactions] {
        transactions.sorted { $0.date > $1.date }
    }
    
    var body: some View {
        List {
            if sortedTransactions.isEmpty {
                ContentUnavailableView(
                    "No Transactions",
                    systemImage: "list.bullet.clipboard",
                    description: Text("No transactions found for this period.")
                )
            } else {
                ForEach(sortedTransactions) { transaction in
                    TransactionRow(transaction: transaction)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedTransaction = transaction
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                transactionToDelete = transaction
                                showingDeleteAlert = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
        }
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingAddTransaction = true
                }) {
                    Image(systemName: "plus")
                        .fontWeight(.semibold)
                }
            }
        }
        .sheet(isPresented: $showingAddTransaction) {
            CategoryAddTransactionView(category: category)
        }
        .sheet(item: $selectedTransaction) { transaction in
            TransactionDetailView(transaction: transaction)
        }
        .alert("Delete Transaction", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {
                transactionToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let transaction = transactionToDelete {
                    deleteTransaction(transaction)
                }
                transactionToDelete = nil
            }
        } message: {
            Text("Are you sure you want to delete this transaction? This action cannot be undone.")
        }
    }
    
    private func deleteTransaction(_ transaction: Transactions) {
        withAnimation(.easeInOut(duration: 0.3)) {
            // Revert account balances
            if let account = transaction.account {
                switch transaction.type {
                case .income:
                    account.balance -= transaction.amount
                case .expense:
                    account.balance += transaction.amount
                case .transfer:
                    account.balance += transaction.amount
                    if let toAccount = transaction.toAccount {
                        toAccount.balance -= transaction.amount
                        toAccount.modifiedAt = Date()
                    }
                }
                account.modifiedAt = Date()
            }
            
            modelContext.delete(transaction)
            
            do {
                try modelContext.save()
            } catch {
                print("Error deleting transaction: \(error)")
            }
        }
    }
}
