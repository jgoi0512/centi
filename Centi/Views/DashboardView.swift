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
    
    @State private var showingAddTransaction = false
    @State private var showingFilter = false
    @State private var selectedAccounts: Set<String> = []
    @State private var selectedCategories: Set<String> = []
    @State private var selectedTypes: Set<Transactions.TransactionType> = []
    
    private var totalBalance: Double {
        accounts.reduce(0) { $0 + $1.balance }
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
        Dictionary(grouping: filteredTransactions.prefix(50)) { transaction in
            Calendar.current.startOfDay(for: transaction.date)
        }
    }
    
    private var hasActiveFilters: Bool {
        !selectedAccounts.isEmpty || !selectedCategories.isEmpty || !selectedTypes.isEmpty
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
            ScrollView {
                VStack(spacing: 20) {
                    // Total Balance Card
                    TotalBalanceCard(balance: totalBalance)
                        .padding(.horizontal)
                    
                    // Recent Transactions
                    VStack(alignment: .leading, spacing: 15) {
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
                        
                        if transactions.isEmpty {
                            EmptyTransactionView()
                                .padding(.horizontal)
                        } else {
                            ForEach(sortedDates, id: \.self) { date in
                                VStack(alignment: .leading, spacing: 10) {
                                    Text(dateLabel(for: date))
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal)
                                        .padding(.top, 10)
                                    
                                    ForEach(groupedTransactions[date] ?? []) { transaction in
                                        DashboardTransactionRow(
                                            transaction: transaction,
                                            onDelete: { deleteTransaction(transaction) }
                                        )
                                        .padding(.horizontal)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.bottom, 100)
                }
                .padding(.top)
            }
            .navigationTitle("Dashboard")
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
                    selectedAccounts: $selectedAccounts,
                    selectedCategories: $selectedCategories,
                    selectedTypes: $selectedTypes
                )
            }
            .background(
                LinearGradient(
                    colors: [Color(.systemBackground), Color(.systemGray6)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
    }
    
    private func deleteTransaction(_ transaction: Transactions) {
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

#Preview {
    DashboardView()
}
