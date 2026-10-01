//
//  MarkShoppingItemPurchasedUseCaseTests.swift
//  Kitchen Companion
//
//  Created by Carmelo Stivala on 1/10/2026.
//

import XCTest
@testable import Kitchen_Companion

final class MarkShoppingItemPurchasedUseCaseTests: XCTestCase {
    private let useCase = MarkShoppingItemPurchasedUseCase()

    private func item(status: ShoppingListItemStatus) -> ShoppingListItem {
        ShoppingListItem(
            id: "SLI-1",
            ingredientName: "Flour",
            quantityNeeded: Quantity(amount: 200, unit: .grams),
            origin: .manuallyAdded,
            status: status
        )
    }

    func test_markPurchased_succeeds_whenItemIsPending() {
        let result = useCase.execute(item: item(status: .pending))

        XCTAssertEqual(result.assertSuccess()?.status, .purchased)
    }

    func test_markPurchased_fails_whenItemAlreadyPurchased() {
        let result = useCase.execute(item: item(status: .purchased))

        XCTAssertEqual(result.assertFailure(), .itemAlreadyPurchased)
    }

    func test_markPurchased_preservesItemDetails_whenSucceeding() {
        let pendingItem = item(status: .pending)

        let result = useCase.execute(item: pendingItem)

        XCTAssertEqual(result.assertSuccess()?.id, pendingItem.id)
        XCTAssertEqual(result.assertSuccess()?.ingredientName, pendingItem.ingredientName)
        XCTAssertEqual(result.assertSuccess()?.quantityNeeded, pendingItem.quantityNeeded)
    }
}
