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
     
     var body: some View {
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
     }
}

#Preview {
    ContentView()
}
