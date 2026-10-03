//
//  PlanExpiryReminderUseCaseTests.swift
//  Kitchen Companion
//
//  Created by Carmelo Stivala on 2/10/2026.
//

import XCTest
@testable import Kitchen_Companion

final class PlanExpiryReminderUseCaseTests: XCTestCase {
    private let useCase = PlanExpiryReminderUseCase()
    private let calendar = Calendar.current

    private func ingredient(expiringAt expiryDate: Date?) -> HouseholdIngredient {
        HouseholdIngredient(
            id: IngredientIdentifier(rawValue: "I-1"),
            name: "Milk",
            quantityOnHand: Quantity(amount: 500, unit: .milliliters),
            expiryDate: expiryDate,
            updatedAt: Date()
        )
    }

    func test_planReminder_isNineAmAWeekBefore_whenIngredientExpiresInThirtyDays() {
        let now = Date()
        let expiry = calendar.date(byAdding: .day, value: 30, to: now)!

        let fireDate = useCase.execute(ingredient: ingredient(expiringAt: expiry), now: now).assertSuccess()

        let expectedDay = calendar.date(byAdding: .day, value: -7, to: expiry)!
        let expected = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: expectedDay)
        XCTAssertEqual(fireDate, expected)
    }

    func test_planReminder_isImmediate_whenIngredientExpiresInThreeDays() {
        let now = Date()
        let expiry = calendar.date(byAdding: .day, value: 3, to: now)!

        let fireDate = useCase.execute(ingredient: ingredient(expiringAt: expiry), now: now).assertSuccess()

        XCTAssertEqual(fireDate, now.addingTimeInterval(PlanExpiryReminderUseCase.immediateReminderDelaySeconds))
    }

    func test_planReminder_succeeds_whenIngredientExpiresRightNow() {
        let now = Date()

        let result = useCase.execute(ingredient: ingredient(expiringAt: now), now: now)

        XCTAssertNotNil(result.assertSuccess())
    }

    func test_planReminder_fails_whenIngredientHasNoExpiryDate() {
        let result = useCase.execute(ingredient: ingredient(expiringAt: nil))

        XCTAssertEqual(result.assertFailure(), .noExpiryDate(ingredientName: "Milk"))
    }

    func test_planReminder_fails_whenIngredientHasAlreadyExpired() {
        let now = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!

        let result = useCase.execute(ingredient: ingredient(expiringAt: yesterday), now: now)

        XCTAssertEqual(result.assertFailure(), .alreadyExpired(ingredientName: "Milk"))
    }
}
