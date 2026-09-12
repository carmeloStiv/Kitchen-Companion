//
//  RecordHouseholdIngredientUseCase.swift
//  Kitchen Companion
//
//  Created by Carmelo Stivala on 12/9/2026.
//

import Foundation

// Creates or updates an ingredient entry; quantity can never be negative.
struct RecordHouseholdIngredientUseCase {
    enum Failure: LocalizedError, Equatable {
        case ingredientNameMissing
        case negativeQuantity

        var errorDescription: String? {
            switch self {
            case .ingredientNameMissing:
                return "Give this ingredient a name before saving it."
            case .negativeQuantity:
                return "The amount on hand can't be negative. Enter 0 if you're out of it."
            }
        }
    }

    func execute(
        name: String,
        quantity: Quantity,
        existingIngredient: HouseholdIngredient?,
        now: Date = Date()
    ) -> Result<HouseholdIngredient, Failure> {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            return .failure(.ingredientNameMissing)
        }
        guard quantity.amount >= 0 else {
            return .failure(.negativeQuantity)
        }

        let ingredient = HouseholdIngredient(
            id: existingIngredient?.id ?? IngredientIdentifier(rawValue: UUID().uuidString),
            name: trimmedName,
            quantityOnHand: quantity,
            updatedAt: now
        )
        return .success(ingredient)
    }
}
