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
    @Environment(\.editMode) private var editMode
    
    // Sort by sortOrder so the list reflects the saved order
    @Query(sort: \Category.sortOrder) private var categories: [Category]
    
    // Local state to handle reordering in the UI before saving to DB
    @State private var localCategories: [Category] = []
    
    @State private var showingAddCategory = false
    @State private var newCategoryName = ""
    @State private var selectedIcon = "tag"
    
    // State for editing, resetting, and rearranging
    @State private var categoryToEdit: Category?
    @State private var showingResetAlert = false
    @State private var isRearranging = false
    
    private let availableIcons = [
        "tag", "cart", "car", "house", "gamecontroller",
        "heart", "airplane", "book", "scissors", "bag", "fork.knife"
    ]
    
    var body: some View {
        NavigationStack {
            List {
                Section("Categories") {
                    ForEach(localCategories) { category in
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
                        .contentShape(Rectangle())
                        // Disable context menu while rearranging to prevent conflicts
                        .contextMenu(isRearranging ? nil : ContextMenu {
                            Button {
                                prepareForEdit(category)
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            
                            Button {
                                startRearranging()
                            } label: {
                                Label("Rearrange", systemImage: "arrow.up.arrow.down")
                            }
                        })
                    }
                    .onDelete(perform: deleteCategories)
                    .onMove(perform: moveCategories)
                    
                    if !isRearranging {
                        Button(action: {
                            prepareForAdd()
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.green)
                                Text("Add Category")
                                    .foregroundColor(.primary)
                            }
                        }
                        .transition(.opacity)
                    }
                }
                
                if !isRearranging {
                    Section {
                        Button(role: .destructive) {
                            showingResetAlert = true
                        } label: {
                            HStack {
                                Spacer()
                                Text("Reset Categories")
                                Spacer()
                            }
                        }
                    }
                    .transition(.opacity)
                }
            }
            .navigationTitle(isRearranging ? "Rearrange Categories" : "Categories")
            .navigationBarTitleDisplayMode(.large)
            .environment(\.editMode, .constant(isRearranging ? .active : .inactive))
            .animation(.default, value: isRearranging)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isRearranging {
                        Button("Save Order") {
                            saveOrder()
                        }
                        .fontWeight(.bold)
                        .transition(.opacity)
                    } else {
                        Button("Done") {
                            dismiss()
                        }
                        .fontWeight(.semibold)
                        .transition(.opacity)
                    }
                }
            }
            .sheet(isPresented: $showingAddCategory) {
                categorySheet
            }
            .alert("Reset Categories", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    resetCategories()
                }
            } message: {
                Text("Are you sure you want to reset the categories? This will delete all current categories and restore the defaults.")
            }
            .onAppear {
                syncLocalCategories()
                createDefaultCategoriesIfNeeded()
            }
            .onChange(of: categories) { _, newValue in
                if !isRearranging {
                    localCategories = newValue
                }
            }
        }
    }
    
    private var categorySheet: some View {
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
            .navigationTitle(categoryToEdit == nil ? "Add Category" : "Edit Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showingAddCategory = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(categoryToEdit == nil ? "Add" : "Save") {
                        saveCategory()
                    }
                    .disabled(newCategoryName.isEmpty)
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    // MARK: - Rearrange Logic
    
    private func startRearranging() {
        withAnimation {
            isRearranging = true
        }
    }
    
    private func moveCategories(from source: IndexSet, to destination: Int) {
        localCategories.move(fromOffsets: source, toOffset: destination)
    }
    
    private func saveOrder() {
        // Update the sortOrder for each category based on the new list order
        for (index, category) in localCategories.enumerated() {
            category.sortOrder = index
        }
        
        do {
            try modelContext.save()
            withAnimation {
                isRearranging = false
            }
        } catch {
            print("Error saving order: \(error)")
        }
    }
    
    // MARK: - CRUD Logic
    
    private func syncLocalCategories() {
        localCategories = categories
    }
    
    private func prepareForAdd() {
        categoryToEdit = nil
        newCategoryName = ""
        selectedIcon = "tag"
        showingAddCategory = true
    }
    
    private func prepareForEdit(_ category: Category) {
        categoryToEdit = category
        newCategoryName = category.name
        selectedIcon = category.icon
        showingAddCategory = true
    }
    
    private func saveCategory() {
        if let category = categoryToEdit {
            // Update existing category
            category.name = newCategoryName
            category.icon = selectedIcon
        } else {
            // Create new category
            // Place it at the end of the list
            let nextSortOrder = (categories.last?.sortOrder ?? 0) + 1
            
            let category = Category(
                name: newCategoryName,
                icon: selectedIcon,
                color: "appBlue", // Default color
                isDefault: false,
                sortOrder: nextSortOrder
            )
            modelContext.insert(category)
        }
        
        do {
            try modelContext.save()
            showingAddCategory = false
            categoryToEdit = nil
        } catch {
            print("Error saving category: \(error)")
        }
    }
    
    private func deleteCategories(offsets: IndexSet) {
        for index in offsets {
            let categoryToDelete = localCategories[index]
            modelContext.delete(categoryToDelete)
        }
        
        localCategories.remove(atOffsets: offsets)
        
        do {
            try modelContext.save()
        } catch {
            print("Error deleting categories: \(error)")
        }
    }
    
    private func createDefaultCategoriesIfNeeded() {
        guard categories.isEmpty else { return }
        insertDefaults()
    }
    
    private func resetCategories() {
        // Delete all categories
        do {
            try modelContext.delete(model: Category.self)
            // Save deletion before inserting defaults to ensure clean slate
            try modelContext.save()
            
            insertDefaults()
        } catch {
            print("Error resetting categories: \(error)")
        }
    }
    
    private func insertDefaults() {
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
        
        // Insert with incrementing sort order
        for (index, category) in defaultCategories.enumerated() {
            category.sortOrder = index
            modelContext.insert(category)
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Error inserting default categories: \(error)")
        }
    }
}
