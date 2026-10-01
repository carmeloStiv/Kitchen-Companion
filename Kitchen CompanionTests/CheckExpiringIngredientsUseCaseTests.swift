//
//  CheckExpiringIngredientsUseCaseTests.swift
//  Kitchen Companion
//
//  Created by Carmelo Stivala on 1/10/2026.
//

import XCTest
@testable import Kitchen_Companion

// Mock IngredientPantry so these tests don't depend on SwiftData or LocalKitchenStore.
private final class MockIngredientPantry: IngredientPantry {
    var ingredients: [HouseholdIngredient]

    init(ingredients: [HouseholdIngredient]) {
        self.ingredients = ingredients
    }

    func allIngredients() -> [HouseholdIngredient] { ingredients }

    func ingredient(named name: String) -> HouseholdIngredient? {
        ingredients.first { $0.normalizedName == name.lowercased() }
    }

    func save(ingredient: HouseholdIngredient) {
        if let index = ingredients.firstIndex(where: { $0.id == ingredient.id }) {
            ingredients[index] = ingredient
        } else {
            ingredients.append(ingredient)
        }
    }

    func ingredientsExpiring(within days: Int, of referenceDate: Date) -> [HouseholdIngredient] {
        let cutoff = Calendar.current.date(byAdding: .day, value: days, to: referenceDate) ?? referenceDate
        return ingredients.filter { ingredient in
            guard let expiryDate = ingredient.expiryDate else { return false }
            return expiryDate <= cutoff
        }
    }
}

final class CheckExpiringIngredientsUseCaseTests: XCTestCase {
    private let useCase = CheckExpiringIngredientsUseCase()
    private let now = Date()

    private func ingredient(name: String, daysUntilExpiry: Int?) -> HouseholdIngredient {
        let expiryDate = daysUntilExpiry.map { Calendar.current.date(byAdding: .day, value: $0, to: now)! }
        return HouseholdIngredient(
            id: IngredientIdentifier(rawValue: name),
            name: name,
            quantityOnHand: Quantity(amount: 1, unit: .pieces),
            expiryDate: expiryDate,
            updatedAt: now
        )
    }

    func test_checkExpiringIngredients_succeeds_returningOnlyIngredientsWithinWindow() {
        let pantry = MockIngredientPantry(ingredients: [
            ingredient(name: "Milk", daysUntilExpiry: 2),
            ingredient(name: "Flour", daysUntilExpiry: 30)
        ])

        let result = useCase.execute(pantry: pantry, withinDays: 3, now: now)

        XCTAssertEqual(result.assertSuccess()?.map(\.name), ["Milk"])
    }

    func test_checkExpiringIngredients_succeeds_sortingSoonestExpiryFirst() {
        let pantry = MockIngredientPantry(ingredients: [
            ingredient(name: "Yoghurt", daysUntilExpiry: 3),
            ingredient(name: "Milk", daysUntilExpiry: 1)
        ])

        let result = useCase.execute(pantry: pantry, withinDays: 5, now: now)

        XCTAssertEqual(result.assertSuccess()?.map(\.name), ["Milk", "Yoghurt"])
    }

    func test_checkExpiringIngredients_excludesIngredientsWithNoExpiryDate() {
        let pantry = MockIngredientPantry(ingredients: [
            ingredient(name: "Salt", daysUntilExpiry: nil)
        ])

        let result = useCase.execute(pantry: pantry, withinDays: 30, now: now)

        XCTAssertEqual(result.assertSuccess(), [])
    }

    func test_checkExpiringIngredients_fails_whenWindowIsZeroOrNegative() {
        let pantry = MockIngredientPantry(ingredients: [])

        let result = useCase.execute(pantry: pantry, withinDays: 0, now: now)

        XCTAssertEqual(result.assertFailure(), .lookAheadWindowNotPositive)
    }
}
