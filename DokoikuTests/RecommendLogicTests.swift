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
        let item1 = Item(name: "カフェ", category: .both)
        let item2 = Item(name: "水族館", category: .outing)
        
        let candidates = [item1, item2]
        
        let result = RecommendLogic.recommend(from: candidates, mode: .outing)
        
        // modeがoutingの時、bothのカテゴリも含まれる
        XCTAssertEqual(result.main?.name != nil, true)
        XCTAssertEqual(result.sub.count, 1)
    }
    
    func testEmptyCandidates() {
        let result = RecommendLogic.recommend(from: [], mode: .food)
        XCTAssertNil(result.main)
        XCTAssertTrue(result.sub.isEmpty)
    }
}
