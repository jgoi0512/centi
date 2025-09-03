//
//  ContentView.swift
//  Centi
//
//  Created by Justin Goi on 30/7/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab = 0
     @State private var showingAddTransaction = false
     
     var body: some View {
         ZStack {
             TabView(selection: $selectedTab) {
                 DashboardView()
                     .tabItem {
                         Label("Dashboard", systemImage: "house.fill")
                     }
                     .tag(0)
                 
                 AccountsView()
                     .tabItem {
                         Label("Accounts", systemImage: "creditcard.fill")
                     }
                     .tag(1)
                 
                 SettingsView()
                     .tabItem {
                         Label("Settings", systemImage: "gear")
                     }
                     .tag(2)
             }
             
             // Floating Add Button
             VStack {
                 Spacer()
                 HStack {
                     Spacer()
                     Button(action: {
                         showingAddTransaction = true
                     }) {
                         Image(systemName: "plus")
                             .font(.title2)
                             .fontWeight(.semibold)
                             .foregroundColor(.white)
                             .frame(width: 60, height: 60)
                             .background(
                                 LinearGradient(
                                     colors: [Color.blue, Color.purple],
                                     startPoint: .topLeading,
                                     endPoint: .bottomTrailing
                                 )
                             )
                             .clipShape(Circle())
                             .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                     }
                     .padding(.trailing, 20)
                     .padding(.bottom, 90)
                 }
             }
         }
         .sheet(isPresented: $showingAddTransaction) {
             AddTransactionView()
         }
     }
}

#Preview {
    ContentView()
}
