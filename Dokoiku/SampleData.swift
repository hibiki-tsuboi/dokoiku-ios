//
//  SampleData.swift
//  Dokoiku
//

import Foundation
import SwiftData

enum SampleData {
    @MainActor
    static func insert(into context: ModelContext) {
        let now = Date()
        let calendar = Calendar.current

        let samples: [(name: String, category: Category, area: String, memo: String, desireLevel: Int, priceLevel: PriceLevel, daysSinceLastVisit: Int?)] = [
            ("サンプルカフェ", .food, "サンプル区A", "コーヒーが美味しい。テラス席が気持ちいい。", 5, .normal, 3),
            ("サンプル割烹", .food, "サンプル区B", "カウンターで揚げたての料理を。記念日に。", 5, .expensive, 28),
            ("サンプルイタリアン", .food, "サンプル区C", "薪窯のピザが絶品。", 4, .normal, nil),
            ("サンプルラーメン", .food, "サンプル区D", "濃厚スープ。並ぶ覚悟必要。", 3, .cheap, 7),
            ("サンプル公園", .outing, "サンプル区E", "ピクニックに最適。早朝の散歩も気持ちいい。", 4, .cheap, 2),
            ("サンプル商店街", .outing, "サンプル区F", "古着屋とカフェ巡り。週末の午後に。", 4, .normal, nil),
            ("サンプル市場", .outing, "サンプル区G", "海鮮丼と温泉。一日楽しめる。", 3, .normal, nil),
            ("サンプル動物園", .outing, "サンプル区H", "ボートに乗れる。動物が見られる。", 4, .cheap, 14)
        ]

        for sample in samples {
            let lastVisited: Date? = sample.daysSinceLastVisit.flatMap {
                calendar.date(byAdding: .day, value: -$0, to: now)
            }

            let item = Item(
                name: sample.name,
                category: sample.category,
                area: sample.area,
                memo: sample.memo,
                desireLevel: sample.desireLevel,
                lastVisited: lastVisited,
                priceLevel: sample.priceLevel,
                visitCount: lastVisited != nil ? 1 : 0
            )
            context.insert(item)

            if let visitDate = lastVisited {
                let visit = Visit(visitedAt: visitDate, item: item)
                context.insert(visit)
            }
        }

        try? context.save()
    }
}
