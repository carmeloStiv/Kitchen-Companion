//
//  TrackIngredientExpiryUseCaseTests.swift
//  Kitchen Companion
//
//  Created by Carmelo Stivala on 1/10/2026.
//

import XCTest
@testable import Kitchen_Companion

final class TrackIngredientExpiryUseCaseTests: XCTestCase {
    private let useCase = TrackIngredientExpiryUseCase()

    private let ingredient = HouseholdIngredient(
        id: IngredientIdentifier(rawValue: "I-1"),
        name: "Milk",
        quantityOnHand: Quantity(amount: 500, unit: .milliliters),
        updatedAt: Date()
    )

    func test_trackExpiry_succeeds_whenDateIsInTheFuture() {
        let now = Date()
        let futureDate = Calendar.current.date(byAdding: .day, value: 5, to: now)!

        let result = useCase.execute(ingredient: ingredient, expiryDate: futureDate, now: now)

        XCTAssertEqual(result.assertSuccess()?.expiryDate, futureDate)
    }

    func test_trackExpiry_succeeds_whenDateIsToday() {
        let now = Date()

        let result = useCase.execute(ingredient: ingredient, expiryDate: now, now: now)

        XCTAssertNotNil(result.assertSuccess())
    }

    func test_trackExpiry_fails_whenDateIsInThePast() {
        let now = Date()
        let pastDate = Calendar.current.date(byAdding: .day, value: -1, to: now)!

        let result = useCase.execute(ingredient: ingredient, expiryDate: pastDate, now: now)

        XCTAssertEqual(result.assertFailure(), .expiryDateInThePast(enteredDate: pastDate))
    }

    func test_trackExpiry_succeeds_whenClearingExpiryDate() {
        var expiringIngredient = ingredient
        expiringIngredient.expiryDate = Date()

        let result = useCase.execute(ingredient: expiringIngredient, expiryDate: nil)

        XCTAssertNil(result.assertSuccess()?.expiryDate)
    }
}
