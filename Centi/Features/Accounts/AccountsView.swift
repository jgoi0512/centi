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
     
     var body: some View {
         NavigationStack {
             ScrollView {
                 VStack(spacing: 15) {
                     if accounts.isEmpty {
                         EmptyAccountsView()
                             .padding()
                     } else {
                         LazyVStack(spacing: 15) {
                             ForEach(accounts) { account in
                                 AccountCard(account: account)
                                     .padding(.horizontal)
                                     .contentShape(Rectangle())
                                     .onTapGesture {
                                         selectedAccount = account
                                     }
                                     .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                         Button("Delete") {
                                             deleteAccount(account)
                                         }
                                         .tint(.red)
                                     }
                             }
                         }
                     }
                 }
                 .padding(.top)
                 .padding(.bottom, 100)
             }
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
