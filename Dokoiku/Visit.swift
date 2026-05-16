//
//  Visit.swift
//  Dokoiku
//

import Foundation
import SwiftData

@Model
final class Visit {
    var id: UUID
    var visitedAt: Date
    var item: Item?

    init(id: UUID = UUID(), visitedAt: Date = Date(), item: Item? = nil) {
        self.id = id
        self.visitedAt = visitedAt
        self.item = item
    }
}
