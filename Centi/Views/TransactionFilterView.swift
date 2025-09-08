//
//  TransactionFilterView.swift
//  Centi
//
//  Created by Justin Goi on 4/9/2025.
//

import SwiftUI
import SwiftData

struct TransactionFilterView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var categories: [Category]
    
    @Binding var selectedCategories: Set<String>
    @Binding var selectedTypes: Set<Transactions.TransactionType>
    
    @State private var tempSelectedCategories: Set<String>
    @State private var tempSelectedTypes: Set<Transactions.TransactionType>
    
    init(selectedCategories: Binding<Set<String>>, selectedTypes: Binding<Set<Transactions.TransactionType>>) {
        self._selectedCategories = selectedCategories
        self._selectedTypes = selectedTypes
        
        self._tempSelectedCategories = State(initialValue: selectedCategories.wrappedValue)
        self._tempSelectedTypes = State(initialValue: selectedTypes.wrappedValue)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Transaction Type") {
                    ForEach(Transactions.TransactionType.allCases, id: \.self) { type in
                        HStack {
                            Image(systemName: tempSelectedTypes.contains(type) ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(tempSelectedTypes.contains(type) ? .blue : .gray)
                            Text(type.rawValue)
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.1)) {
                                if tempSelectedTypes.contains(type) {
                                    tempSelectedTypes.remove(type)
                                } else {
                                    tempSelectedTypes.insert(type)
                                }
                            }
                        }
                    }
                }
                
                Section("Categories") {
                    HStack {
                        Button(tempSelectedCategories.count == categories.count ? "Deselect All" : "Select All") {
                            if tempSelectedCategories.count == categories.count {
                                tempSelectedCategories.removeAll()
                            } else {
                                tempSelectedCategories = Set(categories.map { $0.name })
                            }
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                        Spacer()
                    }
                    
                    ForEach(categories, id: \.id) { category in
                        HStack {
                            Image(systemName: tempSelectedCategories.contains(category.name) ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(tempSelectedCategories.contains(category.name) ? .blue : .gray)
                            
                            Image(systemName: category.icon)
                                .foregroundColor(Color(category.color))
                            
                            Text(category.name)
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.1)) {
                                if tempSelectedCategories.contains(category.name) {
                                    tempSelectedCategories.remove(category.name)
                                } else {
                                    tempSelectedCategories.insert(category.name)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Filter Transactions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        selectedCategories = tempSelectedCategories
                        selectedTypes = tempSelectedTypes
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}