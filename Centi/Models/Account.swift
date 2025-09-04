//
//  Account.swift
//  Centi
//
//  Created by Justin Goi on 27/8/2025.
//

import SwiftUI
import SwiftData

@Model
final class Account {
    var id: UUID = UUID()
    var name: String
    var type: AccountType
    var balance: Double
    var icon: String
    var color: String
    var currency: String?
    var createdAt: Date
    var modifiedAt: Date
    
    @Relationship(deleteRule: .cascade)
    var transactions: [Transactions]?
    
    init(name: String, type: AccountType, balance: Double = 0, icon: String = "creditcard", color: String = "blue", currency: String? = nil) {
        self.name = name
        self.type = type
        self.balance = balance
        self.icon = icon
        self.color = color
        self.currency = currency
        self.createdAt = Date()
        self.modifiedAt = Date()
    }
    
    enum AccountType: String, CaseIterable, Codable {
        case savings = "Savings"
        case transaction = "Transaction"
        case cash = "Cash"
        case credit = "Credit Card"
        case investment = "Investment"
    }
}
