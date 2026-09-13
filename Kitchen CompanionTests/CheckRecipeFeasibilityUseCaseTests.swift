//
//  CheckRecipeFeasibilityUseCaseTests.swift
//  Kitchen Companion
//
//  Created by Carmelo Stivala on 12/9/2026.
//

import XCTest
@testable import Kitchen_Companion

final class CheckRecipeFeasibilityUseCaseTests: XCTestCase {
    private let useCase = CheckRecipeFeasibilityUseCase()

    private func recipe(requiring quantity: Quantity) -> Recipe {
        Recipe(
            id: RecipeIdentifier(rawValue: "R-1"),
            title: "Pancakes",
            ingredients: [RecipeIngredientRequirement(id: "RI-1", ingredientName: "Flour", requiredQuantity: quantity)],
            steps: [RecipeStep(id: "RS-1", instruction: "Mix.", durationSeconds: nil, temperatureCelsius: nil)],
            source: .manualEntry,
            createdAt: Date()
        )
    }

    private func ingredient(name: String = "Flour", quantity: Quantity) -> HouseholdIngredient {
        HouseholdIngredient(id: IngredientIdentifier(rawValue: "I-1"), name: name, quantityOnHand: quantity, updatedAt: Date())
    }

    func test_feasibility_reportsCanBeMade_whenHouseholdHasEnough() {
        let report = useCase.execute(
            recipe: recipe(requiring: Quantity(amount: 200, unit: .grams)),
            householdIngredients: [ingredient(quantity: Quantity(amount: 500, unit: .grams))]
        )

        XCTAssertTrue(report.canBeMadeNow)
    }

    func test_feasibility_reportsCanBeMade_whenHouseholdHasExactlyEnough() {
        let report = useCase.execute(
            recipe: recipe(requiring: Quantity(amount: 200, unit: .grams)),
            householdIngredients: [ingredient(quantity: Quantity(amount: 200, unit: .grams))]
        )

        XCTAssertTrue(report.canBeMadeNow)
    }

    func test_feasibility_reportsShortfall_whenIngredientMissingEntirely() {
        let report = useCase.execute(recipe: recipe(requiring: Quantity(amount: 200, unit: .grams)), householdIngredients: [])

        XCTAssertEqual(report.shortfalls.first?.reason, .missingEntirely)
    }

    func test_feasibility_reportsShortfall_whenQuantityInsufficient() {
        let report = useCase.execute(
            recipe: recipe(requiring: Quantity(amount: 200, unit: .grams)),
            householdIngredients: [ingredient(quantity: Quantity(amount: 50, unit: .grams))]
        )

        XCTAssertEqual(report.shortfalls.first?.reason, .insufficientQuantity(haveQuantity: Quantity(amount: 50, unit: .grams)))
    }

    func test_feasibility_reportsShortfall_whenUnitsCannotBeCompared() {
        let report = useCase.execute(
            recipe: recipe(requiring: Quantity(amount: 200, unit: .grams)),
            householdIngredients: [ingredient(quantity: Quantity(amount: 2, unit: .pieces))]
        )

        XCTAssertEqual(report.shortfalls.first?.reason, .unitMismatch(haveQuantity: Quantity(amount: 2, unit: .pieces)))
    }

    func test_feasibility_matchesIngredientNames_caseAndWhitespaceInsensitively() {
        let report = useCase.execute(
            recipe: recipe(requiring: Quantity(amount: 200, unit: .grams)),
            householdIngredients: [ingredient(name: "  FLOUR  ", quantity: Quantity(amount: 500, unit: .grams))]
        )

        XCTAssertTrue(report.canBeMadeNow)
    }
}
