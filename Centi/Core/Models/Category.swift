//
//  Category.swift
//  Centi
//
//  Created by Justin Goi on 4/9/2025.
//

import SwiftUI
import SwiftData

@Model
final class Category {
    var id: UUID = UUID()
    var name: String = ""
    var icon: String = "tag"
    var color: String = "appBlue"
    var isDefault: Bool = false
    var createdAt: Date = Date()
    
    init(name: String, icon: String = "tag", color: String = "appBlue", isDefault: Bool = false) {
        self.name = name
        self.icon = icon
        self.color = color
        self.isDefault = isDefault
        self.createdAt = Date()
    }
}
