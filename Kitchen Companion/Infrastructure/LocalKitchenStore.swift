//
//  LocalKitchenStore.swift
//  Kitchen Companion
//
//  Created by Carmelo Stivala on 12/9/2026.
//

import Foundation

// Shared live store for ingredients and recipes, so every screen sees the same data.
final class LocalKitchenStore: IngredientPantry, RecipeBook {
    private var ingredients: [HouseholdIngredient]
    private var recipes: [Recipe]

    init(ingredients: [HouseholdIngredient] = SampleKitchenData.ingredients, recipes: [Recipe] = SampleKitchenData.recipes) {
        self.ingredients = ingredients
        self.recipes = recipes
    }

    // MARK: - IngredientPantry

    func allIngredients() -> [HouseholdIngredient] { ingredients }

    func ingredient(named name: String) -> HouseholdIngredient? {
        let normalized = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return ingredients.first { $0.normalizedName == normalized }
    }

    func save(ingredient: HouseholdIngredient) {
        if let index = ingredients.firstIndex(where: { $0.id == ingredient.id }) {
            ingredients[index] = ingredient
        } else {
            ingredients.append(ingredient)
        }
    }

    // MARK: - RecipeBook

    func allRecipes() -> [Recipe] { recipes }

    func recipe(for id: RecipeIdentifier) -> Recipe? {
        recipes.first { $0.id == id }
    }

    func save(recipe: Recipe) {
        if let index = recipes.firstIndex(where: { $0.id == recipe.id }) {
            recipes[index] = recipe
        } else {
            recipes.append(recipe)
        }
    }
}
