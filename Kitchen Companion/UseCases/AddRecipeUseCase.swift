//
//  AddRecipeUseCase.swift
//  Kitchen Companion
//
//  Created by Carmelo Stivala on 12/9/2026.
//

import Foundation

// Saves a recipe (manual or video draft); needs a title, ingredients, and steps.
struct AddRecipeUseCase {
    enum Failure: LocalizedError, Equatable {
        case titleMissing
        case noIngredientsListed
        case noStepsListed
        case ingredientQuantityNotPositive(ingredientName: String)

        var errorDescription: String? {
            switch self {
            case .titleMissing:
                return "Give this recipe a name before saving it."
            case .noIngredientsListed:
                return "This recipe has no ingredients listed. Add at least one - if it came from a video, the automatic transcript may have missed them."
            case .noStepsListed:
                return "This recipe has no steps listed. Add at least one before saving."
            case .ingredientQuantityNotPositive(let ingredientName):
                return "The amount listed for \"\(ingredientName)\" must be greater than zero."
            }
        }
    }

    func execute(
        title: String,
        ingredients: [RecipeIngredientRequirement],
        steps: [RecipeStep],
        source: RecipeSource,
        now: Date = Date()
    ) -> Result<Recipe, Failure> {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            return .failure(.titleMissing)
        }
        guard !ingredients.isEmpty else {
            return .failure(.noIngredientsListed)
        }
        guard !steps.isEmpty else {
            return .failure(.noStepsListed)
        }
        if let invalidIngredient = ingredients.first(where: { $0.requiredQuantity.amount <= 0 }) {
            return .failure(.ingredientQuantityNotPositive(ingredientName: invalidIngredient.ingredientName))
        }

        let recipe = Recipe(
            id: RecipeIdentifier(rawValue: UUID().uuidString),
            title: trimmedTitle,
            ingredients: ingredients,
            steps: steps,
            source: source,
            createdAt: now
        )
        return .success(recipe)
    }
}
