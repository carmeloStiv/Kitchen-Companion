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

    func delete(ingredientID: IngredientIdentifier) {
        ingredients.removeAll { $0.id == ingredientID }
    }

    // Kept here so this in-memory store still conforms to IngredientPantry
    // now that the protocol has this method.
    func ingredientsExpiring(within days: Int, of referenceDate: Date) -> [HouseholdIngredient] {
        let cutoff = Calendar.current.date(byAdding: .day, value: days, to: referenceDate) ?? referenceDate
        return ingredients.filter { ingredient in
            guard let expiryDate = ingredient.expiryDate else { return false }
            return expiryDate <= cutoff
        }
    }

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
