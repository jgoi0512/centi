//
//  SettingsView.swift
//  Centi
//
//  Created by Justin Goi on 3/9/2025.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var currencyManager = CurrencyManager.shared
    @EnvironmentObject private var settingsManager: SettingsManager
    @State private var showingCategoryManagement = false
    @State private var showingRestartAlert = false

    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "N/A"
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Sync") {
                    Toggle("iCloud Sync", isOn: $settingsManager.iCloudSyncEnabled)
                        .onChange(of: settingsManager.iCloudSyncEnabled) { _, newValue in
                            if settingsManager.requiresRestart {
                                showingRestartAlert = true
                            }
                        }
                    
                    HStack {
                        Text("Status:")
                        Spacer()
                        Text(settingsManager.iCloudStatus)
                            .foregroundColor(settingsManager.iCloudStatus == "Available" ? .green : .secondary)
                    }
                    
                    if settingsManager.iCloudSyncEnabled {
                        Text("Your data will sync across all devices signed into the same iCloud account")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Data is stored locally on this device only")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
//                Section("Notifications") {
//                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
//                }
                
                Section("Currency") {
                    Picker("Default Currency", selection: $currencyManager.defaultCurrency) {
                        ForEach(Array(CurrencyManager.currencies.keys.sorted()), id: \.self) { code in
                            HStack {
                                Text("\(code) (\(CurrencyManager.currencies[code]?.0 ?? "$"))")
                            }
                            .tag(code)
                        }
                    }
                    .pickerStyle(.menu)
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
                        Text(appVersion)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingCategoryManagement) {
                CategoryManagementView()
            }
            .alert("Restart Required", isPresented: $showingRestartAlert) {
                Button("OK") {
                    // User acknowledged the restart requirement
                }
            } message: {
                Text("To apply iCloud Sync changes, please restart the app. Your data will be preserved.")
            }
        }
    }
}

#Preview {
    SettingsView()
}
