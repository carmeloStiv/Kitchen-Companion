//
//  DomainProtocols.swift
//  Kitchen Companion
//
//  Created by Carmelo Stivala on 12/9/2026.
//

import Foundation

// Stores and retrieves the household's current ingredient stock.
// ingredientsExpiring(within:of:) is the predicate-driven query that powers
// both the Expiring Soon screen and the widget/notification extension. It's
// on the protocol, not just the SwiftData implementation, so a mock
// repository can satisfy it in tests.
protocol IngredientPantry {
    func allIngredients() -> [HouseholdIngredient]
    func ingredient(named name: String) -> HouseholdIngredient?
    func save(ingredient: HouseholdIngredient)
    func delete(ingredientID: IngredientIdentifier)
    func ingredientsExpiring(within days: Int, of referenceDate: Date) -> [HouseholdIngredient]
}

// Stores and retrieves the household's saved recipes.
protocol RecipeBook {
    func allRecipes() -> [Recipe]
    func recipe(for id: RecipeIdentifier) -> Recipe?
    func save(recipe: Recipe)
}

// Turns a video file into spoken-word text.
protocol VideoTranscribing {
    func transcribe(videoURL: URL) async throws -> String
}

// Stores and retrieves the household's shopping list.
// Kept separate from IngredientPantry because a shopping list item and a
// pantry ingredient are different domain concepts with different
// lifecycles. An item exists to eventually become an ingredient (see
// MarkShoppingItemPurchasedUseCase), not to replace one.
protocol ShoppingListRepository {
    func allItems() -> [ShoppingListItem]
    func item(withID id: String) -> ShoppingListItem?
    func save(item: ShoppingListItem)
    func delete(itemID: String)
}

// Reminds the household before an ingredient reaches its use-by date.
// Kept as a protocol so the reminder rules can be tested without
// scheduling real notifications on a device.
protocol ExpiryReminderScheduling {
    func scheduleReminder(for ingredient: HouseholdIngredient, at fireDate: Date)
    func cancelReminder(forIngredientID ingredientID: IngredientIdentifier)
}
