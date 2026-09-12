//
//  HouseholdIngredient.swift
//  Kitchen Companion
//
//  Created by Carmelo Stivala on 12/9/2026.
//

import Foundation

/// One ingredient the household has on hand. Business Rule: quantityOnHand can never be negative.
struct HouseholdIngredient: Identifiable, Equatable, Codable {
    let id: IngredientIdentifier
    var name: String
    var quantityOnHand: Quantity
    var updatedAt: Date

    /// Normalised for matching against a recipe's ingredient requirements.
    var normalizedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
