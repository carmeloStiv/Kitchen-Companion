//
//  AddShoppingListItemUseCaseTests.swift
//  Kitchen Companion
//
//  Created by Carmelo Stivala on 3/10/2026.
//

import XCTest
@testable import Kitchen_Companion

final class AddShoppingListItemUseCaseTests: XCTestCase {
    private let useCase = AddShoppingListItemUseCase()

    private func item(name: String, status: ShoppingListItemStatus) -> ShoppingListItem {
        ShoppingListItem(
            id: "SLI-1",
            ingredientName: name,
            quantityNeeded: Quantity(amount: 1, unit: .pieces),
            origin: .manuallyAdded,
            status: status
        )
    }

    func test_addShoppingItem_succeeds_withNameAndPositiveQuantity() {
        let result = useCase.execute(name: "Butter", quantity: Quantity(amount: 250, unit: .grams), existingItems: [])

        let added = result.assertSuccess()
        XCTAssertEqual(added?.ingredientName, "Butter")
        XCTAssertEqual(added?.status, .pending)
        XCTAssertEqual(added?.origin, .manuallyAdded)
    }

    func test_addShoppingItem_fails_whenNameIsEmpty() {
        let result = useCase.execute(name: "   ", quantity: Quantity(amount: 1, unit: .pieces), existingItems: [])

        XCTAssertEqual(result.assertFailure(), .ingredientNameMissing)
    }

    func test_addShoppingItem_fails_whenQuantityIsZero() {
        let result = useCase.execute(name: "Butter", quantity: Quantity(amount: 0, unit: .grams), existingItems: [])

        XCTAssertEqual(result.assertFailure(), .quantityNotPositive)
    }

    func test_addShoppingItem_fails_whenIngredientAlreadyPending() {
        let result = useCase.execute(
            name: "butter",
            quantity: Quantity(amount: 100, unit: .grams),
            existingItems: [item(name: "  Butter ", status: .pending)]
        )

        XCTAssertEqual(result.assertFailure(), .duplicatePendingItem(ingredientName: "butter"))
    }

    func test_addShoppingItem_succeeds_whenSameIngredientWasAlreadyPurchased() {
        let result = useCase.execute(
            name: "Butter",
            quantity: Quantity(amount: 100, unit: .grams),
            existingItems: [item(name: "Butter", status: .purchased)]
        )

        XCTAssertNotNil(result.assertSuccess())
    }
}
