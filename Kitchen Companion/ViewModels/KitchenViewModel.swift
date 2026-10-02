//
//  KitchenViewModel.swift
//  Kitchen Companion
//
//  Created by Carmelo Stivala on 12/9/2026.
//

import Foundation
import Combine
import SwiftData
import WidgetKit

// Drives the ingredient inventory and recipe book screens.
// Ingredients persist through the App Group SwiftData store, so the
// Expiring Soon widget reads the same pantry the app shows. Recipes stay in
// an in-memory store for now, they are not part of this round of work.
final class KitchenViewModel: ObservableObject {
    @Published var ingredients: [HouseholdIngredient]
    @Published var recipes: [Recipe]
    @Published var errorMessage: String?

    private let pantry: IngredientPantry
    private let recipeBook: RecipeBook

    private let recordIngredientUseCase = RecordHouseholdIngredientUseCase()
    private let deleteIngredientUseCase = DeleteHouseholdIngredientUseCase()
    private let addRecipeUseCase = AddRecipeUseCase()
    private let checkFeasibilityUseCase = CheckRecipeFeasibilityUseCase()

    init(
        pantry: IngredientPantry = SwiftDataIngredientPantry(context: ModelContext(KitchenCompanionContainer.shared)),
        recipeBook: RecipeBook = LocalKitchenStore()
    ) {
        self.pantry = pantry
        self.recipeBook = recipeBook

        if pantry.allIngredients().isEmpty {
            SampleKitchenData.ingredients.forEach(pantry.save(ingredient:))
        }

        self.ingredients = pantry.allIngredients()
        self.recipes = recipeBook.allRecipes()
    }

    // Records or updates a household ingredient.
    @discardableResult
    func recordIngredient(name: String, quantity: Quantity) -> Bool {
        let existing = pantry.ingredient(named: name)

        switch recordIngredientUseCase.execute(name: name, quantity: quantity, existingIngredient: existing) {
        case .success(let ingredient):
            pantry.save(ingredient: ingredient)
            ingredients = pantry.allIngredients()
            errorMessage = nil
            WidgetCenter.shared.reloadAllTimelines()
            return true
        case .failure(let failure):
            errorMessage = failure.errorDescription
            return false
        }
    }

    // Removes an ingredient the household no longer wants to track.
    @discardableResult
    func deleteIngredient(_ ingredient: HouseholdIngredient) -> Bool {
        let current = ingredients.first { $0.id == ingredient.id }

        switch deleteIngredientUseCase.execute(ingredientID: ingredient.id, existingIngredient: current) {
        case .success(let ingredientID):
            pantry.delete(ingredientID: ingredientID)
            ingredients = pantry.allIngredients()
            errorMessage = nil
            WidgetCenter.shared.reloadAllTimelines()
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
            recipeBook.save(recipe: recipe)
            recipes = recipeBook.allRecipes()
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
