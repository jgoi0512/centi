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
    
    init() {
        do {
            let schema = Schema([Account.self, Transactions.self])
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false, cloudKitDatabase: .automatic)
            container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to configure SwiftData container: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
