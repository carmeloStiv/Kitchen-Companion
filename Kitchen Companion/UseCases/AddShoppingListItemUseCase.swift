//
//  AddShoppingListItemUseCase.swift
//  Kitchen Companion
//
//  Created by Carmelo Stivala on 3/10/2026.
//

import Foundation

// Adds something the household typed onto their shopping list.
// Business rule: an item needs a name and an amount above zero, and an
// ingredient that is already waiting to be bought cannot be added twice.
struct AddShoppingListItemUseCase {
    enum Failure: LocalizedError, Equatable {
        case ingredientNameMissing
        case quantityNotPositive
        case duplicatePendingItem(ingredientName: String)

        var errorDescription: String? {
            switch self {
            case .ingredientNameMissing:
                return "Give this item a name before adding it to the shopping list."
            case .quantityNotPositive:
                return "Enter how much you need to buy, it has to be more than zero."
            case .duplicatePendingItem(let ingredientName):
                return "\"\(ingredientName)\" is already on the shopping list. Check off the existing item instead of adding it twice."
            }
        }
    }

    func execute(
        name: String,
        quantity: Quantity,
        existingItems: [ShoppingListItem]
    ) -> Result<ShoppingListItem, Failure> {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            return .failure(.ingredientNameMissing)
        }
        guard quantity.amount > 0 else {
            return .failure(.quantityNotPositive)
        }

        let normalizedName = trimmedName.lowercased()
        let alreadyPending = existingItems.contains {
            $0.normalizedIngredientName == normalizedName && $0.status == .pending
        }
        guard !alreadyPending else {
            return .failure(.duplicatePendingItem(ingredientName: trimmedName))
        }

        let item = ShoppingListItem(
            id: UUID().uuidString,
            ingredientName: trimmedName,
            quantityNeeded: quantity,
            origin: .manuallyAdded,
            status: .pending
        )
        return .success(item)
    }
}
