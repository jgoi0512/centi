//
//  CategoriesView.swift
//  Centi
//
//  Created by Justin Goi on 13/1/2026.

import SwiftUI
import SwiftData

struct CategoriesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var categories: [Category]
    @Query private var transactions: [Transactions]
    @StateObject private var currencyManager = CurrencyManager.shared
    @State private var selectedTimeRange: TimeRange = .all
    @State private var currentDate = Date()
    
    enum TimeRange: String, CaseIterable {
        case day = "Day"
        case week = "Week"
        case month = "Month"
        case year = "Year"
        case all = "All"
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Time Filter Picker
                VStack(spacing: 12) {
                    Picker("Time Range", selection: $selectedTimeRange) {
                        ForEach(TimeRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // Date Navigation
                    HStack {
                        Button(action: moveDateBackward) {
                            Image(systemName: "chevron.left")
                                .padding(10)
                        }
                        .disabled(selectedTimeRange == .all)
                        
                        Spacer()
                        
                        Text(formattedDateRange)
                            .font(.headline)
                        
                        Spacer()
                        
                        Button(action: moveDateForward) {
                            Image(systemName: "chevron.right")
                                .padding(10)
                        }
                        .disabled(isCurrentDateInFuture || selectedTimeRange == .all)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
                .background(Color(.systemBackground))
                
                // Summary Cards
                HStack(spacing: 15) {
                    SummaryCard(
                        title: "Income",
                        amount: totalIncome,
                        color: .green,
                        currencyManager: currencyManager
                    )
                    
                    SummaryCard(
                        title: "Expenses",
                        amount: totalExpense,
                        color: .red,
                        currencyManager: currencyManager
                    )
                }
                .padding(.horizontal)
                .padding(.bottom)
                
                // Categories List
                List {
                    ForEach(categoriesWithTransactions) { data in
                        NavigationLink(destination: CategoryDetailView(
                            category: data.category,
                            transactions: data.transactions,
                            dateRangeTitle: formattedDateRange
                        )) {
                            HStack {
                                Image(systemName: data.category.icon)
                                    .font(.title3)
                                    .foregroundColor(Color(data.category.color))
                                    .frame(width: 36, height: 36)
                                    .background(
                                        Circle()
                                            .fill(Color(data.category.color).opacity(0.1))
                                    )
                                
                                VStack(alignment: .leading) {
                                    Text(data.category.name)
                                        .font(.headline)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing) {
                                    Text(currencyManager.formatAmount(data.total))
                                        .fontWeight(.semibold)
                                        .foregroundColor(data.total < 0 ? .red : (data.total > 0 ? .green : .primary))
                                    
                                    Text("\(data.transactions.count) trans.")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
                .listStyle(.inset)
            }
            .navigationTitle("Categories")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Today") {
                        currentDate = Date()
                    }
                    .font(.caption)
                    .disabled(Calendar.current.isDateInToday(currentDate) || selectedTimeRange == .all)
                }
            }
            .onAppear {
                createDefaultCategoriesIfNeeded()
            }
        }
    }
    
    // MARK: - Logic Helpers
    
    struct CategoryData: Identifiable {
        var id: UUID { category.id }
        let category: Category
        let transactions: [Transactions]
        let total: Double
    }
    
    private var filteredTransactions: [Transactions] {
        if selectedTimeRange == .all {
            return transactions
        }
        
        _ = Calendar.current
        let interval = dateInterval(for: selectedTimeRange, date: currentDate)
        
        return transactions.filter { transaction in
            transaction.date >= interval.start && transaction.date < interval.end
        }
    }
    
    private var categoriesWithTransactions: [CategoryData] {
        let relevantTransactions = filteredTransactions
        
        // Group transactions by category name
        let grouped = Dictionary(grouping: relevantTransactions) { $0.category }
        
        // Map to CategoryData
        let data = categories.map { category in
            let catTransactions = grouped[category.name] ?? []
            
            // Calculate total impact (Income positive, Expense negative)
            let total = catTransactions.reduce(0.0) { result, transaction in
                switch transaction.type {
                case .income:
                    return result + transaction.amount
                case .expense:
                    return result - transaction.amount
                case .transfer:
                    return result // Transfers don't affect net category summary usually
                }
            }
            
            return CategoryData(category: category, transactions: catTransactions, total: total)
        }
        
        // Sort by activity (absolute total value)
        return data.sorted { abs($0.total) > abs($1.total) }
    }
    
    private var totalIncome: Double {
        filteredTransactions
            .filter { $0.type == .income }
            .reduce(0) { $0 + $1.amount }
    }
    
    private var totalExpense: Double {
        filteredTransactions
            .filter { $0.type == .expense }
            .reduce(0) { $0 + $1.amount }
    }
    
    private func createDefaultCategoriesIfNeeded() {
        guard categories.isEmpty else { return }
        
        let defaultCategories = [
            Category(name: "Food & Dining", icon: "fork.knife", color: "appOrange", isDefault: true),
            Category(name: "Shopping", icon: "bag", color: "appPurple", isDefault: true),
            Category(name: "Transportation", icon: "car", color: "appBlue", isDefault: true),
            Category(name: "Bills & Utilities", icon: "house", color: "appRed", isDefault: true),
            Category(name: "Entertainment", icon: "gamecontroller", color: "appGreen", isDefault: true),
            Category(name: "Health & Fitness", icon: "heart", color: "appPink", isDefault: true),
            Category(name: "Travel", icon: "airplane", color: "appIndigo", isDefault: true),
            Category(name: "Education", icon: "book", color: "appYellow", isDefault: true),
            Category(name: "Personal Care", icon: "scissors", color: "appTeal", isDefault: true),
            Category(name: "Other", icon: "tag", color: "appGray", isDefault: true)
        ]
        
        for category in defaultCategories {
            modelContext.insert(category)
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Error creating default categories: \(error)")
        }
    }
    
    // MARK: - Date Logic
    
    private func dateInterval(for range: TimeRange, date: Date) -> DateInterval {
        let calendar = Calendar.current
        
        switch range {
        case .day:
            return calendar.dateInterval(of: .day, for: date)!
        case .week:
            return calendar.dateInterval(of: .weekOfYear, for: date)!
        case .month:
            return calendar.dateInterval(of: .month, for: date)!
        case .year:
            return calendar.dateInterval(of: .year, for: date)!
        case .all:
            return DateInterval(start: .distantPast, end: .distantFuture)
        }
    }
    
    private func moveDateBackward() {
        if selectedTimeRange == .all { return }
        
        let calendar = Calendar.current
        switch selectedTimeRange {
        case .day:
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
        case .week:
            currentDate = calendar.date(byAdding: .weekOfYear, value: -1, to: currentDate) ?? currentDate
        case .month:
            currentDate = calendar.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
        case .year:
            currentDate = calendar.date(byAdding: .year, value: -1, to: currentDate) ?? currentDate
        case .all:
            break
        }
    }
    
    private func moveDateForward() {
        if selectedTimeRange == .all { return }
        
        let calendar = Calendar.current
        switch selectedTimeRange {
        case .day:
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        case .week:
            currentDate = calendar.date(byAdding: .weekOfYear, value: 1, to: currentDate) ?? currentDate
        case .month:
            currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
        case .year:
            currentDate = calendar.date(byAdding: .year, value: 1, to: currentDate) ?? currentDate
        case .all:
            break
        }
    }
    
    private var isCurrentDateInFuture: Bool {
        if selectedTimeRange == .all { return false }
        
        _ = Calendar.current
        let today = Date()
        let interval = dateInterval(for: selectedTimeRange, date: currentDate)
        return interval.end > today
    }
    
    private var formattedDateRange: String {
        let formatter = DateFormatter()
        
        switch selectedTimeRange {
        case .day:
            if Calendar.current.isDateInToday(currentDate) { return "Today" }
            formatter.dateStyle = .medium
            return formatter.string(from: currentDate)
        case .week:
            let interval = dateInterval(for: .week, date: currentDate)
            formatter.dateFormat = "MMM d"
            let start = formatter.string(from: interval.start)
            let end = formatter.string(from: interval.end.addingTimeInterval(-1))
            return "\(start) - \(end)"
        case .month:
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: currentDate)
        case .year:
            formatter.dateFormat = "yyyy"
            return formatter.string(from: currentDate)
        case .all:
            return "All Time"
        }
    }
}

// Helper View for Summaries
struct SummaryCard: View {
    let title: String
    let amount: Double
    let color: Color
    let currencyManager: CurrencyManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(currencyManager.formatAmount(amount))
                .font(.headline)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
}
