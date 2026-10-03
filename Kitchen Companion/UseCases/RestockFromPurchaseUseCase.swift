//
//  RestockFromPurchaseUseCase.swift
//  Kitchen Companion
//
//  Created by Carmelo Stivala on 3/10/2026.
//

import Foundation

// Works out the pantry stock after the household buys a shopping list item.
// Bought amounts are added to what is already on hand. If the pantry holds
// that ingredient in a different unit, the app does not guess a conversion,
// it asks the household to update the amount themselves.
struct RestockFromPurchaseUseCase {
    enum Failure: LocalizedError, Equatable {
        case unitsDoNotMatch(ingredientName: String)

        var errorDescription: String? {
            switch self {
            case .unitsDoNotMatch(let ingredientName):
                return "\"\(ingredientName)\" is stored in your pantry in a different unit to what you bought, so the amounts can't be added together automatically. Update its amount yourself."
            }
        }
    }

    func execute(
        item: ShoppingListItem,
        existingIngredient: HouseholdIngredient?,
        now: Date = Date()
    ) -> Result<HouseholdIngredient, Failure> {
        guard var ingredient = existingIngredient else {
            let newIngredient = HouseholdIngredient(
                id: IngredientIdentifier(rawValue: UUID().uuidString),
                name: item.ingredientName,
                quantityOnHand: item.quantityNeeded,
                updatedAt: now
            )
            return .success(newIngredient)
        }

        guard ingredient.quantityOnHand.unit == item.quantityNeeded.unit else {
            return .failure(.unitsDoNotMatch(ingredientName: ingredient.name))
        }

        ingredient.quantityOnHand.amount += item.quantityNeeded.amount
        ingredient.updatedAt = now
        return .success(ingredient)
    }
}
