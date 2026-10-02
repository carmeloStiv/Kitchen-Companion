//
//  DeleteHouseholdIngredientUseCase.swift
//  Kitchen Companion
//
//  Created by Carmelo Stivala on 1/10/2026.
//

import Foundation

// Removes an ingredient the household no longer wants to track.
// Business rule: can only delete an ingredient that's still actually in the
// pantry, not one that was already removed elsewhere in the meantime.
struct DeleteHouseholdIngredientUseCase {
    enum Failure: LocalizedError, Equatable {
        case ingredientNotFound

        var errorDescription: String? {
            switch self {
            case .ingredientNotFound:
                return "This ingredient is no longer in your pantry. It may have already been removed."
            }
        }
    }

    func execute(
        ingredientID: IngredientIdentifier,
        existingIngredient: HouseholdIngredient?
    ) -> Result<IngredientIdentifier, Failure> {
        guard let existingIngredient, existingIngredient.id == ingredientID else {
            return .failure(.ingredientNotFound)
        }
        return .success(existingIngredient.id)
    }
}
