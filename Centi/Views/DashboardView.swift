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
    @Query(sort: \Transactions.date, order: .reverse, animation: .default) private var transactions: [Transactions]
    
    @State private var showingAddTransaction = false
    @State private var showingFilter = false
    @State private var selectedAccounts: Set<String> = []
    @State private var selectedCategories: Set<String> = []
    @State private var selectedTypes: Set<Transactions.TransactionType> = []
    @State private var selectedTransaction: Transactions?
    @State private var transactionToDelete: Transactions?
    @State private var showingDeleteAlert = false
    
    private var totalBalance: Double {
        if selectedAccounts.isEmpty {
            return accounts.reduce(0) { $0 + $1.balance }
        } else {
            return accounts.filter { selectedAccounts.contains($0.name) }
                          .reduce(0) { $0 + $1.balance }
        }
    }
    
    private var filteredTransactions: [Transactions] {
        transactions.filter { transaction in
            let accountMatch = selectedAccounts.isEmpty || selectedAccounts.contains(transaction.account?.name ?? "")
            let categoryMatch = selectedCategories.isEmpty || selectedCategories.contains(transaction.category)
            let typeMatch = selectedTypes.isEmpty || selectedTypes.contains(transaction.type)
            
            return accountMatch && categoryMatch && typeMatch
        }
    }
    
    private var groupedTransactions: [Date: [Transactions]] {
        let limitedTransactions = Array(filteredTransactions.prefix(100))
        return Dictionary(grouping: limitedTransactions) { transaction in
            Calendar.current.startOfDay(for: transaction.date)
        }
    }
    
    private var hasActiveFilters: Bool {
        !selectedCategories.isEmpty || !selectedTypes.isEmpty
    }
    
    private var sortedDates: [Date] {
        groupedTransactions.keys.sorted(by: >)
    }
    
    private func dateLabel(for date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Total Balance Card - Fixed at top
                TotalBalanceCard(
                    balance: totalBalance,
                    accounts: accounts,
                    selectedAccounts: $selectedAccounts
                )
                .padding(.horizontal)
                .padding(.top, 8)
                .background(Color(.systemBackground))
                .zIndex(1)
                    
                    // Recent Transactions List
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Text("Recent Transactions")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Button(action: {
                                showingFilter = true
                            }) {
                                Image(systemName: hasActiveFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                                    .foregroundColor(hasActiveFilters ? .blue : .gray)
                                    .font(.title2)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 15)
                        .background(Color(.systemBackground))
                        
                        if transactions.isEmpty {
                            EmptyTransactionView()
                                .padding(.horizontal)
                        } else {
                            List {
                                ForEach(sortedDates, id: \.self) { date in
                                    Section {
                                        ForEach(groupedTransactions[date] ?? []) { transaction in
                                            TransactionRow(transaction: transaction)
                                                .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                                                .onTapGesture {
                                                    selectedTransaction = transaction
                                                }
                                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                                    Button("Delete") {
                                                        transactionToDelete = transaction
                                                        showingDeleteAlert = true
                                                    }
                                                    .tint(.red)
                                                }
                                        }
                                    } header: {
                                        Text(dateLabel(for: date))
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.secondary)
                                            .textCase(nil)
                                    }
                                }
                            }
                            .listStyle(.insetGrouped)
                        }
                    }
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
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
                AddTransactionView()
            }
            .sheet(isPresented: $showingFilter) {
                TransactionFilterView(
                    selectedCategories: $selectedCategories,
                    selectedTypes: $selectedTypes
                )
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
    }
    
    private func deleteTransaction(_ transaction: Transactions) {
        withAnimation(.easeInOut(duration: 0.3)) {
            // Update account balances before deleting the transaction
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

#Preview {
    DashboardView()
}
