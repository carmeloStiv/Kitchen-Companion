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
    @Published var shoppingItems: [ShoppingListItem]
    @Published var errorMessage: String?
    @Published var noticeMessage: String?

    private let pantry: IngredientPantry
    private let recipeBook: RecipeBook
    private let shoppingList: ShoppingListRepository
    private let reminderScheduler: ExpiryReminderScheduling

    private let recordIngredientUseCase = RecordHouseholdIngredientUseCase()
    private let deleteIngredientUseCase = DeleteHouseholdIngredientUseCase()
    private let addRecipeUseCase = AddRecipeUseCase()
    private let checkFeasibilityUseCase = CheckRecipeFeasibilityUseCase()
    private let planExpiryReminderUseCase = PlanExpiryReminderUseCase()
    private let trackExpiryUseCase = TrackIngredientExpiryUseCase()
    private let addShoppingItemUseCase = AddShoppingListItemUseCase()
    private let generateShoppingListUseCase = GenerateShoppingListUseCase()
    private let markPurchasedUseCase = MarkShoppingItemPurchasedUseCase()
    private let restockUseCase = RestockFromPurchaseUseCase()

    init(
        pantry: IngredientPantry = SwiftDataIngredientPantry(context: ModelContext(KitchenCompanionContainer.shared)),
        recipeBook: RecipeBook = LocalKitchenStore(),
        shoppingList: ShoppingListRepository = SwiftDataShoppingListRepository(context: ModelContext(KitchenCompanionContainer.shared)),
        reminderScheduler: ExpiryReminderScheduling = KitchenViewModel.defaultReminderScheduler()
    ) {
        self.pantry = pantry
        self.recipeBook = recipeBook
        self.shoppingList = shoppingList
        self.reminderScheduler = reminderScheduler

        if pantry.allIngredients().isEmpty {
            SampleKitchenData.ingredients.forEach(pantry.save(ingredient:))
        }

        self.ingredients = pantry.allIngredients()
        self.recipes = recipeBook.allRecipes()
        self.shoppingItems = shoppingList.allItems()
        scheduleExpiryReminders()
    }

    // UI tests pass -disableReminders so no permission prompt gets in the way.
    private static func defaultReminderScheduler() -> ExpiryReminderScheduling {
        if ProcessInfo.processInfo.arguments.contains("-disableReminders") {
            return SilentExpiryReminderScheduler()
        }
        return UserNotificationExpiryReminderScheduler()
    }

    // Sets up a reminder for every ingredient that has a use-by date still
    // ahead of it. Ingredients without one, or already expired, get none.
    private func scheduleExpiryReminders() {
        for ingredient in ingredients {
            switch planExpiryReminderUseCase.execute(ingredient: ingredient) {
            case .success(let fireDate):
                reminderScheduler.scheduleReminder(for: ingredient, at: fireDate)
            case .failure:
                reminderScheduler.cancelReminder(forIngredientID: ingredient.id)
            }
        }
    }

    // Records or updates a household ingredient, along with its use-by date
    // (nil means it has none). An unchanged date is left alone, so fixing the
    // quantity of an ingredient that has already expired still works.
    @discardableResult
    func recordIngredient(name: String, quantity: Quantity, expiryDate: Date?) -> Bool {
        let existing = pantry.ingredient(named: name)

        switch recordIngredientUseCase.execute(name: name, quantity: quantity, existingIngredient: existing) {
        case .success(let recorded):
            var ingredient = recorded
            if expiryDate != existing?.expiryDate {
                switch trackExpiryUseCase.execute(ingredient: recorded, expiryDate: expiryDate) {
                case .success(let tracked):
                    ingredient = tracked
                case .failure(let failure):
                    errorMessage = failure.errorDescription
                    return false
                }
            }
            pantry.save(ingredient: ingredient)
            ingredients = pantry.allIngredients()
            errorMessage = nil
            scheduleExpiryReminders()
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
            reminderScheduler.cancelReminder(forIngredientID: ingredientID)
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

    // Adds something the household typed onto the shopping list.
    @discardableResult
    func addShoppingItem(name: String, quantity: Quantity) -> Bool {
        switch addShoppingItemUseCase.execute(name: name, quantity: quantity, existingItems: shoppingItems) {
        case .success(let item):
            shoppingList.save(item: item)
            shoppingItems = shoppingList.allItems()
            errorMessage = nil
            return true
        case .failure(let failure):
            errorMessage = failure.errorDescription
            return false
        }
    }

    // Puts everything a recipe is missing onto the shopping list. Items that
    // are already waiting to be bought are skipped, not added twice.
    func addMissingIngredientsToShoppingList(for recipe: Recipe) {
        var addedCount = 0
        var unresolved: [String] = []

        for shortfall in feasibility(for: recipe).shortfalls {
            switch generateShoppingListUseCase.execute(shortfall: shortfall, recipeID: recipe.id, existingItems: shoppingItems) {
            case .success(let item):
                shoppingList.save(item: item)
                shoppingItems = shoppingList.allItems()
                addedCount += 1
            case .failure(let failure):
                if case .cannotDetermineQuantity = failure {
                    unresolved.append(failure.errorDescription ?? "")
                }
            }
        }

        var message = addedCount == 0
            ? "Nothing new to add. Everything missing is already on your shopping list."
            : "Added \(addedCount) \(addedCount == 1 ? "item" : "items") to your shopping list."
        if !unresolved.isEmpty {
            message += " " + unresolved.joined(separator: " ")
        }
        noticeMessage = message
    }

    // Ticks an item off once bought, and adds the amount to the pantry.
    func markPurchased(_ item: ShoppingListItem) {
        switch markPurchasedUseCase.execute(item: item) {
        case .success(let purchased):
            shoppingList.save(item: purchased)
            shoppingItems = shoppingList.allItems()
            errorMessage = nil
            restockPantry(from: purchased)
        case .failure(let failure):
            errorMessage = failure.errorDescription
        }
    }

    func deleteShoppingItem(_ item: ShoppingListItem) {
        shoppingList.delete(itemID: item.id)
        shoppingItems = shoppingList.allItems()
    }

    private func restockPantry(from purchased: ShoppingListItem) {
        let existing = pantry.ingredient(named: purchased.ingredientName)
        switch restockUseCase.execute(item: purchased, existingIngredient: existing) {
        case .success(let ingredient):
            pantry.save(ingredient: ingredient)
            ingredients = pantry.allIngredients()
            WidgetCenter.shared.reloadAllTimelines()
        case .failure(let failure):
            noticeMessage = failure.errorDescription
        }
    }

    // Checks one recipe against current stock.
    func feasibility(for recipe: Recipe) -> RecipeFeasibilityReport {
        checkFeasibilityUseCase.execute(recipe: recipe, householdIngredients: ingredients)
    }
}
