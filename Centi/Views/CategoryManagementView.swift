//
//  CategoryManagementView.swift
//  Centi
//
//  Created by Justin Goi on 4/9/2025.
//

import SwiftUI
import SwiftData

struct CategoryManagementView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var categories: [Category]
    
    @State private var showingAddCategory = false
    @State private var newCategoryName = ""
    @State private var selectedIcon = "tag"
    
    private let availableIcons = [
        "tag", "cart", "car", "house", "gamecontroller",
        "heart", "airplane", "book", "scissors", "bag"
    ]
    
    var body: some View {
        NavigationStack {
            List {
                Section("Categories") {
                    ForEach(categories) { category in
                        HStack {
                            Image(systemName: category.icon)
                                .foregroundColor(.primary)
                                .frame(width: 30)
                            
                            Text(category.name)
                            
                            Spacer()
                            
                            if category.isDefault {
                                Text("Default")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .onDelete(perform: deleteCategories)
                    
                    Button(action: {
                        showingAddCategory = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.green)
                            Text("Add Category")
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
            .navigationTitle("Categories")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showingAddCategory) {
                addCategorySheet
            }
            .onAppear {
                createDefaultCategoriesIfNeeded()
            }
        }
    }
    
    private var addCategorySheet: some View {
        NavigationStack {
            Form {
                Section("Category Details") {
                    TextField("Category Name", text: $newCategoryName)
                    
                    Picker("Icon", selection: $selectedIcon) {
                        ForEach(availableIcons, id: \.self) { icon in
                            HStack {
                                Image(systemName: icon)
                                Text(icon.capitalized)
                            }
                            .tag(icon)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                }
                
                Section {
                    HStack {
                        Image(systemName: selectedIcon)
                            .foregroundColor(.primary)
                            .frame(width: 30)
                        Text("Preview: \(newCategoryName)")
                            .foregroundColor(newCategoryName.isEmpty ? .secondary : .primary)
                    }
                }
            }
            .navigationTitle("Add Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        resetForm()
                        showingAddCategory = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        addCategory()
                    }
                    .disabled(newCategoryName.isEmpty)
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    private func addCategory() {
        let category = Category(
            name: newCategoryName,
            icon: selectedIcon,
            color: "appBlue", // Default color since colors won't be displayed
            isDefault: false
        )
        
        modelContext.insert(category)
        
        do {
            try modelContext.save()
            resetForm()
            showingAddCategory = false
        } catch {
            print("Error saving category: \(error)")
        }
    }
    
    private func deleteCategories(offsets: IndexSet) {
        for index in offsets {
            let category = categories[index]
            if !category.isDefault {
                modelContext.delete(category)
            }
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Error deleting categories: \(error)")
        }
    }
    
    private func resetForm() {
        newCategoryName = ""
        selectedIcon = "tag"
    }
    
    private func createDefaultCategoriesIfNeeded() {
        guard categories.isEmpty else { return }
        
        let defaultCategories = [
            Category(name: "Food & Dining", icon: "fork.knife", color: "orange", isDefault: true),
            Category(name: "Shopping", icon: "bag", color: "purple", isDefault: true),
            Category(name: "Transportation", icon: "car", color: "blue", isDefault: true),
            Category(name: "Bills & Utilities", icon: "house", color: "red", isDefault: true),
            Category(name: "Entertainment", icon: "gamecontroller", color: "green", isDefault: true),
            Category(name: "Health & Fitness", icon: "heart", color: "pink", isDefault: true),
            Category(name: "Travel", icon: "airplane", color: "indigo", isDefault: true),
            Category(name: "Education", icon: "book", color: "yellow", isDefault: true),
            Category(name: "Personal Care", icon: "scissors", color: "teal", isDefault: true),
            Category(name: "Other", icon: "tag", color: "gray", isDefault: true)
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
}
