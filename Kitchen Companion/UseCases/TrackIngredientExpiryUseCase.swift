//
//  TrackIngredientExpiryUseCase.swift
//  Kitchen Companion
//
//  Created by Carmelo Stivala on 1/10/2026.
//

import Foundation

// Sets or clears the expiry date on a household ingredient.
// Passing nil for expiryDate clears it, for an ingredient that turned out
// not to be perishable, or was recorded by mistake.
struct TrackIngredientExpiryUseCase {
    enum Failure: LocalizedError, Equatable {
        case expiryDateInThePast(enteredDate: Date)

        var errorDescription: String? {
            switch self {
            case .expiryDateInThePast:
                return "That use-by date has already passed. Check the date on the packaging and try again."
            }
        }
    }

    func execute(
        ingredient: HouseholdIngredient,
        expiryDate: Date?,
        now: Date = Date()
    ) -> Result<HouseholdIngredient, Failure> {
        if let expiryDate, expiryDate < Calendar.current.startOfDay(for: now) {
            return .failure(.expiryDateInThePast(enteredDate: expiryDate))
        }

        var updated = ingredient
        updated.expiryDate = expiryDate
        updated.updatedAt = now
        return .success(updated)
    }
}
