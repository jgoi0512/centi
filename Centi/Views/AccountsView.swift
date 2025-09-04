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
     
     var body: some View {
         NavigationStack {
             ScrollView {
                 VStack(spacing: 15) {
                     if accounts.isEmpty {
                         EmptyAccountsView()
                             .padding()
                     } else {
                         ForEach(accounts) { account in
                             AccountCard(account: account)
                                 .padding(.horizontal)
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
         }
     }
}

#Preview {
    AccountsView()
}
