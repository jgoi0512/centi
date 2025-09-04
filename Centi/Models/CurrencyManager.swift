//
//  CurrencyManager.swift
//  Centi
//
//  Created by Justin Goi on 4/9/2025.
//

import SwiftUI

class CurrencyManager: ObservableObject {
    @Published var defaultCurrency: String {
        didSet {
            UserDefaults.standard.set(defaultCurrency, forKey: "defaultCurrency")
        }
    }
    
    static let shared = CurrencyManager()
    
    private init() {
        if let savedCurrency = UserDefaults.standard.string(forKey: "defaultCurrency") {
            self.defaultCurrency = savedCurrency
        } else {
            // Set default currency based on user's locale
            let localeCurrency = Locale.current.currency?.identifier ?? "USD"
            let supportedCurrency = Self.currencies.keys.contains(localeCurrency) ? localeCurrency : "USD"
            self.defaultCurrency = supportedCurrency
            UserDefaults.standard.set(supportedCurrency, forKey: "defaultCurrency")
        }
    }
    
    static let currencies = [
        "USD": ("$", "USD"),
        "EUR": ("€", "EUR"),
        "GBP": ("£", "GBP"),
        "AUD": ("$", "AUD"),
        "CAD": ("$", "CAD"),
        "JPY": ("¥", "JPY"),
        "CHF": ("CHF", "CHF"),
        "CNY": ("¥", "CNY")
    ]
    
    func symbol(for currency: String) -> String {
        return Self.currencies[currency]?.0 ?? "$"
    }
    
    func formatAmount(_ amount: Double, currency: String? = nil) -> String {
        let currencyCode = currency ?? defaultCurrency
        let symbol = symbol(for: currencyCode)
        return "\(symbol)\(String(format: "%.2f", amount))"
    }
}