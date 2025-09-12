//
//  CentiApp.swift
//  Centi
//
//  Created by Justin Goi on 30/7/2025.
//

import SwiftUI
import SwiftData

@main
struct CentiApp: App {
    let container: ModelContainer
    @StateObject private var settingsManager = SettingsManager.shared
    
    init() {
        do {
            let schema = Schema([Account.self, Transactions.self, Category.self])
            
            let iCloudSyncEnabled = UserDefaults.standard.object(forKey: "iCloudSyncEnabled") as? Bool ?? true
            
            let config = ModelConfiguration(
                schema: schema, 
                cloudKitDatabase: iCloudSyncEnabled ? .private("iCloud.com.jgoi.centiApp") : .none
            )
            
            container = try ModelContainer(for: schema, configurations: config)
            
            // Mark settings as applied
            UserDefaults.standard.set(iCloudSyncEnabled, forKey: "lastUsediCloudSyncEnabled")
            
        } catch {
            print("SwiftData container error: \(error)")
            
            // If CloudKit fails, try without CloudKit
            do {
                let schema = Schema([Account.self, Transactions.self, Category.self])
                
                let fallbackConfig = ModelConfiguration(
                    schema: schema, 
                    cloudKitDatabase: .none
                )
                
                container = try ModelContainer(for: schema, configurations: [fallbackConfig])
                
                // Update settings to reflect that CloudKit is disabled
                UserDefaults.standard.set(false, forKey: "iCloudSyncEnabled")
                UserDefaults.standard.set(false, forKey: "lastUsediCloudSyncEnabled")
                
                print("Fallback: Running without CloudKit sync")
            } catch {
                fatalError("Failed to configure SwiftData container even without CloudKit: \(error)")
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settingsManager)
        }
        .modelContainer(container)
    }
}
