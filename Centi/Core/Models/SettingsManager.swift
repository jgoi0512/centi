//
//  SettingsManager.swift
//  Centi
//
//  Created by Claude on 11/9/2025.
//

import SwiftUI
import Foundation
import CloudKit

@MainActor
class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    
    @Published var iCloudSyncEnabled: Bool {
        didSet {
            UserDefaults.standard.set(iCloudSyncEnabled, forKey: "iCloudSyncEnabled")
            // When toggled, we need to restart the app for the change to take effect
            // as SwiftData container configuration can't be changed at runtime
        }
    }
    
    @Published var iCloudStatus: String = "Checking..."
    
    private init() {
        // Temporarily default to false due to CloudKit relationship requirements
        self.iCloudSyncEnabled = UserDefaults.standard.object(forKey: "iCloudSyncEnabled") as? Bool ?? true
        checkiCloudStatus()
    }
    
    var requiresRestart: Bool {
        let currentSetting = UserDefaults.standard.object(forKey: "iCloudSyncEnabled") as? Bool ?? true
        let lastUsedSetting = UserDefaults.standard.object(forKey: "lastUsediCloudSyncEnabled") as? Bool ?? true
        return currentSetting != lastUsedSetting
    }
    
    func markSettingsAsApplied() {
        UserDefaults.standard.set(iCloudSyncEnabled, forKey: "lastUsediCloudSyncEnabled")
    }
    
    private func checkiCloudStatus() {
        CKContainer.default().accountStatus { [weak self] status, error in
            Task { @MainActor in
                guard let self = self else { return }
                
                if let error = error {
                    self.iCloudStatus = "Error: \(error.localizedDescription)"
                    return
                }
                
                switch status {
                case .available:
                    self.iCloudStatus = "Available"
                case .noAccount:
                    self.iCloudStatus = "No iCloud Account"
                case .restricted:
                    self.iCloudStatus = "Restricted"
                case .couldNotDetermine:
                    self.iCloudStatus = "Could Not Determine"
                case .temporarilyUnavailable:
                    self.iCloudStatus = "Temporarily Unavailable"
                @unknown default:
                    self.iCloudStatus = "Unknown Status"
                }
            }
        }
    }
    
    func refreshiCloudStatus() {
        checkiCloudStatus()
    }
}
