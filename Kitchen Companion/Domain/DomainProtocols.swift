//
//  DomainProtocols.swift
//  Kitchen Companion
//
//  Created by Carmelo Stivala on 12/9/2026.
//

import Foundation

/// Stores and retrieves the household's current ingredient stock.
protocol IngredientPantry {
    func allIngredients() -> [HouseholdIngredient]
    func ingredient(named name: String) -> HouseholdIngredient?
    func save(ingredient: HouseholdIngredient)
}

/// Stores and retrieves the household's saved recipes.
protocol RecipeBook {
    func allRecipes() -> [Recipe]
    func recipe(for id: RecipeIdentifier) -> Recipe?
    func save(recipe: Recipe)
}

/// Turns a video file into spoken-word text.
protocol VideoTranscribing {
    func transcribe(videoURL: URL) async throws -> String
}
