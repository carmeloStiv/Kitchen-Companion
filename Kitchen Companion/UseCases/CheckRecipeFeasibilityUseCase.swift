//
//  CheckRecipeFeasibilityUseCase.swift
//  Kitchen Companion
//
//  Created by Carmelo Stivala on 12/9/2026.
//

import Foundation

// Compares a recipe's ingredients against household stock and reports any shortfalls.
struct CheckRecipeFeasibilityUseCase {
    func execute(recipe: Recipe, householdIngredients: [HouseholdIngredient]) -> RecipeFeasibilityReport {
        let stockByName = Dictionary(
            householdIngredients.map { ($0.normalizedName, $0) },
            uniquingKeysWith: { first, _ in first }
        )

        let shortfalls: [IngredientShortfall] = recipe.ingredients.compactMap { requirement in
            let normalizedRequirementName = requirement.ingredientName
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .lowercased()

            guard let stocked = stockByName[normalizedRequirementName] else {
                return IngredientShortfall(requirement: requirement, reason: .missingEntirely)
            }

            switch stocked.quantityOnHand.covers(requirement.requiredQuantity) {
            case .some(true):
                return nil
            case .some(false):
                return IngredientShortfall(requirement: requirement, reason: .insufficientQuantity(haveQuantity: stocked.quantityOnHand))
            case .none:
                return IngredientShortfall(requirement: requirement, reason: .unitMismatch(haveQuantity: stocked.quantityOnHand))
            }
        }

        return RecipeFeasibilityReport(recipeID: recipe.id, shortfalls: shortfalls)
    }
}
