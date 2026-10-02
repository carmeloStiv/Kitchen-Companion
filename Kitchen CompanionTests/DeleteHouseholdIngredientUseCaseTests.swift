//
//  DeleteHouseholdIngredientUseCaseTests.swift
//  Kitchen Companion
//
//  Created by Carmelo Stivala on 1/10/2026.
//

import XCTest
@testable import Kitchen_Companion

final class DeleteHouseholdIngredientUseCaseTests: XCTestCase {
    private let useCase = DeleteHouseholdIngredientUseCase()

    private let ingredient = HouseholdIngredient(
        id: IngredientIdentifier(rawValue: "I-1"),
        name: "Flour",
        quantityOnHand: Quantity(amount: 500, unit: .grams),
        updatedAt: Date()
    )

    func test_deleteIngredient_succeeds_whenIngredientExists() {
        let result = useCase.execute(ingredientID: ingredient.id, existingIngredient: ingredient)

        XCTAssertEqual(result.assertSuccess(), ingredient.id)
    }

    func test_deleteIngredient_fails_whenIngredientDoesNotExist() {
        let result = useCase.execute(ingredientID: ingredient.id, existingIngredient: nil)

        XCTAssertEqual(result.assertFailure(), .ingredientNotFound)
    }

    func test_deleteIngredient_fails_whenExistingIngredientHasADifferentID() {
        let otherIngredient = HouseholdIngredient(
            id: IngredientIdentifier(rawValue: "I-2"),
            name: "Sugar",
            quantityOnHand: Quantity(amount: 200, unit: .grams),
            updatedAt: Date()
        )

        let result = useCase.execute(ingredientID: ingredient.id, existingIngredient: otherIngredient)

        XCTAssertEqual(result.assertFailure(), .ingredientNotFound)
    }
}
