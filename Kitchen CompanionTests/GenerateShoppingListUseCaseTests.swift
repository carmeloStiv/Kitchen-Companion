//
//  GenerateShoppingListUseCaseTests.swift
//  Kitchen Companion
//
//  Created by Carmelo Stivala on 1/10/2026.
//

import XCTest
@testable import Kitchen_Companion

final class GenerateShoppingListUseCaseTests: XCTestCase {
    private let useCase = GenerateShoppingListUseCase()
    private let recipeID = RecipeIdentifier(rawValue: "R-1")

    private func requirement(quantity: Quantity) -> RecipeIngredientRequirement {
        RecipeIngredientRequirement(id: "RI-1", ingredientName: "Flour", requiredQuantity: quantity)
    }

    func test_generateShoppingListItem_succeeds_withFullQuantity_whenIngredientMissingEntirely() {
        let shortfall = IngredientShortfall(
            requirement: requirement(quantity: Quantity(amount: 200, unit: .grams)),
            reason: .missingEntirely
        )

        let result = useCase.execute(shortfall: shortfall, recipeID: recipeID, existingItems: [])

        XCTAssertEqual(result.assertSuccess()?.quantityNeeded, Quantity(amount: 200, unit: .grams))
    }

    func test_generateShoppingListItem_succeeds_withShortfallAmount_whenQuantityInsufficient() {
        let shortfall = IngredientShortfall(
            requirement: requirement(quantity: Quantity(amount: 200, unit: .grams)),
            reason: .insufficientQuantity(haveQuantity: Quantity(amount: 50, unit: .grams))
        )

        let result = useCase.execute(shortfall: shortfall, recipeID: recipeID, existingItems: [])

        XCTAssertEqual(result.assertSuccess()?.quantityNeeded, Quantity(amount: 150, unit: .grams))
    }

    func test_generateShoppingListItem_fails_whenUnitsCannotBeCompared() {
        let shortfall = IngredientShortfall(
            requirement: requirement(quantity: Quantity(amount: 200, unit: .grams)),
            reason: .unitMismatch(haveQuantity: Quantity(amount: 2, unit: .pieces))
        )

        let result = useCase.execute(shortfall: shortfall, recipeID: recipeID, existingItems: [])

        XCTAssertEqual(result.assertFailure(), .cannotDetermineQuantity(ingredientName: "Flour"))
    }

    func test_generateShoppingListItem_fails_whenIngredientAlreadyPendingOnList() {
        let shortfall = IngredientShortfall(
            requirement: requirement(quantity: Quantity(amount: 200, unit: .grams)),
            reason: .missingEntirely
        )
        let existingItem = ShoppingListItem(
            id: "SLI-1",
            ingredientName: "  FLOUR  ",
            quantityNeeded: Quantity(amount: 100, unit: .grams),
            origin: .manuallyAdded,
            status: .pending
        )

        let result = useCase.execute(shortfall: shortfall, recipeID: recipeID, existingItems: [existingItem])

        XCTAssertEqual(result.assertFailure(), .duplicatePendingItem(ingredientName: "Flour"))
    }

    func test_generateShoppingListItem_succeeds_whenExistingItemForIngredientIsAlreadyPurchased() {
        let shortfall = IngredientShortfall(
            requirement: requirement(quantity: Quantity(amount: 200, unit: .grams)),
            reason: .missingEntirely
        )
        let purchasedItem = ShoppingListItem(
            id: "SLI-1",
            ingredientName: "Flour",
            quantityNeeded: Quantity(amount: 100, unit: .grams),
            origin: .manuallyAdded,
            status: .purchased
        )

        let result = useCase.execute(shortfall: shortfall, recipeID: recipeID, existingItems: [purchasedItem])

        XCTAssertNotNil(result.assertSuccess())
    }
}
