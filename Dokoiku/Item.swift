//
//  Item.swift
//  Dokoiku
//
//  Created by Hibiki Tsuboi on 2026/05/10.
//

import Foundation
import SwiftData

enum Category: String, Codable, CaseIterable, Identifiable {
    case food = "ごはん"
    case outing = "おでかけ"
    
    var id: String { rawValue }
}

enum PriceLevel: String, Codable, CaseIterable, Identifiable {
    case cheap = "安い"
    case normal = "普通"
    case expensive = "高い"
    
    var id: String { rawValue }
}

@Model
final class Item {
    var id: UUID
    var name: String
    var category: Category
    var area: String
    var memo: String
    var desireLevel: Int // 1 to 5
    var lastVisited: Date?
    var priceLevel: PriceLevel
    var visitCount: Int
    var createdAt: Date
    
    init(id: UUID = UUID(),
         name: String,
         category: Category,
         area: String = "",
         memo: String = "",
         desireLevel: Int = 3,
         lastVisited: Date? = nil,
         priceLevel: PriceLevel = .normal,
         visitCount: Int = 0,
         createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.category = category
        self.area = area
        self.memo = memo
        self.desireLevel = desireLevel
        self.lastVisited = lastVisited
        self.priceLevel = priceLevel
        self.visitCount = visitCount
        self.createdAt = createdAt
    }
}
