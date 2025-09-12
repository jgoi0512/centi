//
//  Transactions.swift
//  Centi
//
//  Created by Justin Goi on 3/9/2025.
//

import SwiftData
import SwiftUI

@Model
final class Transactions {
    var id: UUID = UUID()
    var amount: Double = 0.0
    var type: TransactionType = TransactionType.expense
    var category: String = ""
    var note: String?
    var date: Date = Date()
    var createdAt: Date = Date()
    
    var account: Account?
    var toAccount: Account?
    
    init(amount: Double, type: TransactionType, category: String, note: String? = nil, date: Date = Date(), account: Account? = nil, toAccount: Account? = nil) {
        self.amount = amount
        self.type = type
        self.category = category
        self.note = note
        self.date = date
        self.createdAt = Date()
        self.account = account
        self.toAccount = toAccount
    }
    
    enum TransactionType: String, CaseIterable, Codable {
        case income = "Income"
        case expense = "Expense"
        case transfer = "Transfer"
    }
}
