//
//  KitchenUITests.swift
//  Kitchen Companion
//
//  Created by Carmelo Stivala on 12/9/2026.
//

import XCTest

final class KitchenUITests: XCTestCase {
    func test_ingredientsTab_showsSeededIngredients() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.staticTexts["Plain Flour"].waitForExistence(timeout: 5))
    }

    func test_recipesTab_showsFeasibilityStatus() {
        let app = XCUIApplication()
        app.launch()

        app.tabBars.buttons["Recipes"].tap()

        XCTAssertTrue(app.staticTexts["Simple Pancakes"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Ready to Cook"].waitForExistence(timeout: 5))
    }

    func test_recipeDetail_showsIngredientChecklistAndStartableTimer() {
        let app = XCUIApplication()
        app.launch()

        app.tabBars.buttons["Recipes"].tap()
        app.staticTexts["Simple Pancakes"].tap()

        XCTAssertTrue(app.staticTexts["200 g Plain Flour"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Start 2-Minute Timer"].waitForExistence(timeout: 5))
        app.buttons["Start 2-Minute Timer"].tap()

        // The label re-renders every second, so assert the button was replaced by a countdown
        // rather than pinning an exact transient second value that could race the clock.
        let buttonGone = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: buttonGone, object: app.buttons["Start 2-Minute Timer"])
        XCTAssertEqual(XCTWaiter().wait(for: [expectation], timeout: 3), .completed)
    }
}
