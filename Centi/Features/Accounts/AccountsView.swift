//
//  AccountsView.swift
//  Centi
//
//  Created by Justin Goi on 3/9/2025.
//

import SwiftUI
import SwiftData

struct AccountsView: View {
     @Environment(\.modelContext) private var modelContext
     @Query private var accounts: [Account]
     @State private var showingAddAccount = false
     @State private var selectedAccount: Account?
     
     // New state variables for deletion confirmation
     @State private var accountToDelete: Account?
     @State private var showingDeleteAlert = false
     
     var body: some View {
         NavigationStack {
             List {
                 if accounts.isEmpty {
                     EmptyAccountsView()
                         .listRowSeparator(.hidden)
                         .listRowBackground(Color.clear)
                 } else {
                     ForEach(accounts) { account in
                         AccountCard(account: account)
                             .contentShape(Rectangle())
                             .onTapGesture {
                                 selectedAccount = account
                             }
                             .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                 Button(role: .destructive) {
                                     accountToDelete = account
                                     showingDeleteAlert = true
                                 } label: {
                                     Label("Delete", systemImage: "trash")
                                 }
                             }
                             .listRowSeparator(.hidden)
                             .listRowBackground(Color.clear)
                     }
                 }
             }
             .listStyle(.plain)
             .navigationTitle("Accounts")
             .toolbar {
                 ToolbarItem(placement: .navigationBarTrailing) {
                     Button(action: {
                         showingAddAccount = true
                     }) {
                         Image(systemName: "plus")
                             .font(.title3)
                     }
                 }
             }
             .sheet(isPresented: $showingAddAccount) {
                 AddAccountView()
             }
             .sheet(item: $selectedAccount) { account in
                 AccountDetailView(account: account)
             }
             // Alert for deletion confirmation
             .alert("Delete Account", isPresented: $showingDeleteAlert) {
                 Button("Cancel", role: .cancel) {
                     accountToDelete = nil
                 }
                 Button("Delete", role: .destructive) {
                     if let account = accountToDelete {
                         deleteAccount(account)
                     }
                     accountToDelete = nil
                 }
             } message: {
                 Text("Are you sure you want to delete this account? This will also delete all associated transactions. This action cannot be undone.")
             }
         }
     }
     
     private func deleteAccount(_ account: Account) {
         modelContext.delete(account)
         
         do {
             try modelContext.save()
         } catch {
             print("Error deleting account: \(error)")
         }
     }
}

#Preview {
    AccountsView()
}
