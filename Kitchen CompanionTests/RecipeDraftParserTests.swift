//
//  RecipeDraftParserTests.swift
//  Kitchen Companion
//
//  Created by Carmelo Stivala on 12/9/2026.
//

import XCTest
@testable import Kitchen_Companion

final class RecipeDraftParserTests: XCTestCase {
    func test_parse_extractsIngredientLine_withGrams() {
        let draft = RecipeDraftParser.parse(transcript: "200g plain flour. Mix well.", suggestedTitle: "Test")

        XCTAssertEqual(draft.ingredients.first?.ingredientName, "Plain Flour")
        XCTAssertEqual(draft.ingredients.first?.requiredQuantity, Quantity(amount: 200, unit: .grams))
    }

    func test_parse_extractsIngredientLine_withCups() {
        let draft = RecipeDraftParser.parse(transcript: "2 cups of sugar. Whisk it in.", suggestedTitle: "Test")

        XCTAssertEqual(draft.ingredients.first?.ingredientName, "Sugar")
        XCTAssertEqual(draft.ingredients.first?.requiredQuantity, Quantity(amount: 2, unit: .cups))
    }

    func test_parse_treatsNonIngredientLines_asSteps() {
        let draft = RecipeDraftParser.parse(transcript: "Preheat the oven. Mix the batter until smooth.", suggestedTitle: "Test")

        XCTAssertEqual(draft.steps.count, 2)
        XCTAssertTrue(draft.ingredients.isEmpty)
    }

    func test_parse_returnsEmptyDraft_forBlankTranscript() {
        let draft = RecipeDraftParser.parse(transcript: "", suggestedTitle: "Test")

        XCTAssertTrue(draft.ingredients.isEmpty)
        XCTAssertTrue(draft.steps.isEmpty)
    }
}
