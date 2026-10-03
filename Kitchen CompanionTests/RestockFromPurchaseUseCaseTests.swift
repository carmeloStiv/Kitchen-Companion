//
//  RestockFromPurchaseUseCaseTests.swift
//  Kitchen Companion
//
//  Created by Carmelo Stivala on 3/10/2026.
//

import XCTest
@testable import Kitchen_Companion

final class RestockFromPurchaseUseCaseTests: XCTestCase {
    private let useCase = RestockFromPurchaseUseCase()

    private let boughtFlour = ShoppingListItem(
        id: "SLI-1",
        ingredientName: "Plain Flour",
        quantityNeeded: Quantity(amount: 300, unit: .grams),
        origin: .manuallyAdded,
        status: .purchased
    )

    func test_restock_createsNewIngredient_whenPantryDoesNotHaveIt() {
        let result = useCase.execute(item: boughtFlour, existingIngredient: nil)

        let ingredient = result.assertSuccess()
        XCTAssertEqual(ingredient?.name, "Plain Flour")
        XCTAssertEqual(ingredient?.quantityOnHand, Quantity(amount: 300, unit: .grams))
    }

    func test_restock_addsBoughtAmountToStock_whenUnitsMatch() {
        let existing = HouseholdIngredient(
            id: IngredientIdentifier(rawValue: "I-1"),
            name: "Plain Flour",
            quantityOnHand: Quantity(amount: 200, unit: .grams),
            updatedAt: Date()
        )

        let result = useCase.execute(item: boughtFlour, existingIngredient: existing)

        XCTAssertEqual(result.assertSuccess()?.quantityOnHand, Quantity(amount: 500, unit: .grams))
        XCTAssertEqual(result.assertSuccess()?.id, existing.id)
    }

    func test_restock_keepsUseByDate_whenAddingToExistingStock() {
        let expiryDate = Date().addingTimeInterval(86_400)
        let existing = HouseholdIngredient(
            id: IngredientIdentifier(rawValue: "I-1"),
            name: "Plain Flour",
            quantityOnHand: Quantity(amount: 200, unit: .grams),
            expiryDate: expiryDate,
            updatedAt: Date()
        )

        let result = useCase.execute(item: boughtFlour, existingIngredient: existing)

        XCTAssertEqual(result.assertSuccess()?.expiryDate, expiryDate)
    }

    func test_restock_fails_whenPantryHoldsItInADifferentUnit() {
        let existing = HouseholdIngredient(
            id: IngredientIdentifier(rawValue: "I-1"),
            name: "Plain Flour",
            quantityOnHand: Quantity(amount: 2, unit: .cups),
            updatedAt: Date()
        )

        let result = useCase.execute(item: boughtFlour, existingIngredient: existing)

        XCTAssertEqual(result.assertFailure(), .unitsDoNotMatch(ingredientName: "Plain Flour"))
    }
}
