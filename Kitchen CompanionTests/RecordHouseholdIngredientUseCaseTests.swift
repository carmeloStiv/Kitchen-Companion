//
//  RecordHouseholdIngredientUseCaseTests.swift
//  Kitchen Companion
//
//  Created by Carmelo Stivala on 12/9/2026.
//

import XCTest
@testable import Kitchen_Companion

final class RecordHouseholdIngredientUseCaseTests: XCTestCase {
    private let useCase = RecordHouseholdIngredientUseCase()

    func test_record_succeeds_whenCreatingANewIngredient() {
        let result = useCase.execute(name: "Flour", quantity: Quantity(amount: 500, unit: .grams), existingIngredient: nil)

        let ingredient = result.assertSuccess()
        XCTAssertEqual(ingredient?.name, "Flour")
        XCTAssertEqual(ingredient?.quantityOnHand, Quantity(amount: 500, unit: .grams))
    }

    func test_record_succeeds_andKeepsSameID_whenUpdatingAnExistingIngredient() {
        let existing = HouseholdIngredient(id: IngredientIdentifier(rawValue: "I-1"), name: "Flour", quantityOnHand: Quantity(amount: 100, unit: .grams), updatedAt: Date())

        let result = useCase.execute(name: "Flour", quantity: Quantity(amount: 500, unit: .grams), existingIngredient: existing)

        XCTAssertEqual(result.assertSuccess()?.id, existing.id)
    }

    func test_record_fails_whenNameIsEmpty() {
        let result = useCase.execute(name: "   ", quantity: Quantity(amount: 1, unit: .pieces), existingIngredient: nil)

        XCTAssertEqual(result.assertFailure(), .ingredientNameMissing)
    }

    func test_record_fails_whenQuantityIsNegative() {
        let result = useCase.execute(name: "Flour", quantity: Quantity(amount: -1, unit: .grams), existingIngredient: nil)

        XCTAssertEqual(result.assertFailure(), .negativeQuantity)
    }

    func test_record_succeeds_whenQuantityIsExactlyZero() {
        let result = useCase.execute(name: "Flour", quantity: Quantity(amount: 0, unit: .grams), existingIngredient: nil)

        XCTAssertNotNil(result.assertSuccess())
    }
}
