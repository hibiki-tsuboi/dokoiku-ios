//
//  RecommendLogicTests.swift
//  DokoikuTests
//

import XCTest
@testable import Dokoiku

final class RecommendLogicTests: XCTestCase {
    
    func testRecommendOnlyFood() {
        let item1 = Item(name: "ラーメン", category: .food)
        let item2 = Item(name: "公園", category: .outing)
        
        let candidates = [item1, item2]
        
        let result = RecommendLogic.recommend(from: candidates, mode: .food)
        
        XCTAssertEqual(result.main?.name, "ラーメン")
        XCTAssertTrue(result.sub.isEmpty)
    }
    
    func testRecommendBoth() {
        let item1 = Item(name: "カフェ", category: .food)
        let item2 = Item(name: "水族館", category: .outing)
        
        let candidates = [item1, item2]
        
        // modeがnilの時、すべてのカテゴリが含まれる
        let result = RecommendLogic.recommend(from: candidates, mode: nil)
        
        XCTAssertEqual(result.main?.name != nil, true)
        XCTAssertEqual(result.sub.count, 1)
    }
    
    func testEmptyCandidates() {
        let result = RecommendLogic.recommend(from: [], mode: .food)
        XCTAssertNil(result.main)
        XCTAssertTrue(result.sub.isEmpty)
    }

    func testRecommendFiltersByArea() {
        let shinjuku = Item(name: "新宿ラーメン", category: .food, area: "新宿")
        let yokohama = Item(name: "横浜カフェ", category: .food, area: "横浜")
        let chiba = Item(name: "千葉そば", category: .food, area: "千葉")

        let candidates = [shinjuku, yokohama, chiba]

        let result = RecommendLogic.recommend(from: candidates, mode: .food, area: "新宿")

        XCTAssertEqual(result.main?.name, "新宿ラーメン")
        XCTAssertTrue(result.sub.isEmpty)
    }

    func testRecommendCombinesAreaAndMode() {
        let shinjukuFood = Item(name: "新宿ラーメン", category: .food, area: "新宿")
        let shinjukuOuting = Item(name: "新宿御苑", category: .outing, area: "新宿")
        let yokohamaFood = Item(name: "横浜カフェ", category: .food, area: "横浜")

        let candidates = [shinjukuFood, shinjukuOuting, yokohamaFood]

        let result = RecommendLogic.recommend(from: candidates, mode: .food, area: "新宿")

        XCTAssertEqual(result.main?.name, "新宿ラーメン")
        XCTAssertTrue(result.sub.isEmpty)
    }

    func testRecommendReturnsNilWhenNoMatchInArea() {
        let yokohama = Item(name: "横浜カフェ", category: .food, area: "横浜")

        let result = RecommendLogic.recommend(from: [yokohama], mode: .food, area: "新宿")

        XCTAssertNil(result.main)
        XCTAssertTrue(result.sub.isEmpty)
    }

    func testNilAreaKeepsAllCandidates() {
        let shinjuku = Item(name: "新宿ラーメン", category: .food, area: "新宿")
        let yokohama = Item(name: "横浜カフェ", category: .food, area: "横浜")

        let result = RecommendLogic.recommend(from: [shinjuku, yokohama], mode: .food, area: nil)

        XCTAssertNotNil(result.main)
        XCTAssertEqual(result.sub.count, 1)
    }
}
