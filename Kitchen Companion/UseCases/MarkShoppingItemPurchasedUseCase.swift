//
//  MarkShoppingItemPurchasedUseCase.swift
//  Kitchen Companion
//
//  Created by Carmelo Stivala on 1/10/2026.
//

import Foundation

// Marks a shopping list item as purchased once the household has bought it.
// Business rule: only a pending item can be purchased, purchased is a
// terminal state (see ShoppingListItemStatus). Whether this should also
// update the household's pantry stock is a decision for whoever calls this
// use case, not this use case itself, matching how AddRecipeUseCase and
// RecordHouseholdIngredientUseCase leave saving to the caller.
struct MarkShoppingItemPurchasedUseCase {
    enum Failure: LocalizedError, Equatable {
        case itemAlreadyPurchased

        var errorDescription: String? {
            switch self {
            case .itemAlreadyPurchased:
                return "This item has already been marked as purchased."
            }
        }
    }

    func execute(item: ShoppingListItem) -> Result<ShoppingListItem, Failure> {
        guard item.status == .pending else {
            return .failure(.itemAlreadyPurchased)
        }

        var purchased = item
        purchased.status = .purchased
        return .success(purchased)
    }
}
