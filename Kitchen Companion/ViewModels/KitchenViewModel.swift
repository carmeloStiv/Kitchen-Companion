//
//  KitchenViewModel.swift
//  Kitchen Companion
//
//  Created by Carmelo Stivala on 12/9/2026.
//

import Foundation
import Combine

// Drives the ingredient inventory and recipe book screens.
final class KitchenViewModel: ObservableObject {
    @Published var ingredients: [HouseholdIngredient]
    @Published var recipes: [Recipe]
    @Published var errorMessage: String?

    private let store: IngredientPantry & RecipeBook

    private let recordIngredientUseCase = RecordHouseholdIngredientUseCase()
    private let addRecipeUseCase = AddRecipeUseCase()
    private let checkFeasibilityUseCase = CheckRecipeFeasibilityUseCase()

    init(store: IngredientPantry & RecipeBook = LocalKitchenStore()) {
        self.store = store
        self.ingredients = store.allIngredients()
        self.recipes = store.allRecipes()
    }

    // Records or updates a household ingredient.
    @discardableResult
    func recordIngredient(name: String, quantity: Quantity) -> Bool {
        let existing = store.ingredient(named: name)

        switch recordIngredientUseCase.execute(name: name, quantity: quantity, existingIngredient: existing) {
        case .success(let ingredient):
            store.save(ingredient: ingredient)
            ingredients = store.allIngredients()
            errorMessage = nil
            return true
        case .failure(let failure):
            errorMessage = failure.errorDescription
            return false
        }
    }

    // Saves a new recipe.
    @discardableResult
    func addRecipe(title: String, ingredients: [RecipeIngredientRequirement], steps: [RecipeStep], source: RecipeSource) -> Bool {
        switch addRecipeUseCase.execute(title: title, ingredients: ingredients, steps: steps, source: source) {
        case .success(let recipe):
            store.save(recipe: recipe)
            recipes = store.allRecipes()
            errorMessage = nil
            return true
        case .failure(let failure):
            errorMessage = failure.errorDescription
            return false
        }
    }

    // Checks one recipe against current stock.
    func feasibility(for recipe: Recipe) -> RecipeFeasibilityReport {
        checkFeasibilityUseCase.execute(recipe: recipe, householdIngredients: ingredients)
    }
}
