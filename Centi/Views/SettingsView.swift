//
//  SettingsView.swift
//  Centi
//
//  Created by Justin Goi on 3/9/2025.
//

import SwiftUI

struct SettingsView: View {
    @State private var iCloudSyncEnabled = true
    @State private var notificationsEnabled = false
    @State private var currency = "USD"
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Sync") {
                    Toggle("iCloud Sync", isOn: $iCloudSyncEnabled)
                    Text("Sync your data across all your devices")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section("Notifications") {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                }
                
                Section("Currency") {
                    Picker("Currency", selection: $currency) {
                        Text("USD ($)").tag("USD")
                        Text("EUR (€)").tag("EUR")
                        Text("GBP (£)").tag("GBP")
                        Text("AUD ($)").tag("AUD")
                    }
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
