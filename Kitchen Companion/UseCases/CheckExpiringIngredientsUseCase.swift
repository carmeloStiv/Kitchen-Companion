//
//  CheckExpiringIngredientsUseCase.swift
//  Kitchen Companion
//
//  Created by Carmelo Stivala on 1/10/2026.
//

import Foundation

// Finds household ingredients expiring soon, soonest first.
// Thin wrapper around IngredientPantry.ingredientsExpiring(within:of:), so
// the Expiring Soon screen, the widget, and the notification extension all
// get the same sorted, validated result instead of each re-sorting it.
struct CheckExpiringIngredientsUseCase {
    enum Failure: LocalizedError, Equatable {
        case lookAheadWindowNotPositive

        var errorDescription: String? {
            switch self {
            case .lookAheadWindowNotPositive:
                return "Enter how many days ahead to check for, at least 1."
            }
        }
    }

    func execute(
        pantry: IngredientPantry,
        withinDays days: Int,
        now: Date = Date()
    ) -> Result<[HouseholdIngredient], Failure> {
        guard days > 0 else {
            return .failure(.lookAheadWindowNotPositive)
        }

        let expiring = pantry.ingredientsExpiring(within: days, of: now)
            .sorted { ($0.expiryDate ?? .distantFuture) < ($1.expiryDate ?? .distantFuture) }
        return .success(expiring)
    }
}
