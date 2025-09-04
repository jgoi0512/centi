//
//  SettingsView.swift
//  Centi
//
//  Created by Justin Goi on 3/9/2025.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var currencyManager = CurrencyManager.shared
    @State private var iCloudSyncEnabled = true
    @State private var notificationsEnabled = false
    @State private var showingCategoryManagement = false
    
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
                    Picker("Default Currency", selection: $currencyManager.defaultCurrency) {
                        ForEach(Array(CurrencyManager.currencies.keys.sorted()), id: \.self) { code in
                            HStack {
                                Text("\(code) (\(CurrencyManager.currencies[code]?.0 ?? "$"))")
                            }
                            .tag(code)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section("Categories") {
                    Button(action: {
                        showingCategoryManagement = true
                    }) {
                        HStack {
                            Image(systemName: "tag")
                                .foregroundColor(.blue)
                            Text("Manage Categories")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
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
            .sheet(isPresented: $showingCategoryManagement) {
                CategoryManagementView()
            }
        }
    }
}

#Preview {
    SettingsView()
}
