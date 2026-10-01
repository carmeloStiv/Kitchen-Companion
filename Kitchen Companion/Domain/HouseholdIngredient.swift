//
//  HouseholdIngredient.swift
//  Kitchen Companion
//
//  Created by Carmelo Stivala on 12/9/2026.
//

import Foundation

// One ingredient the household has on hand. Business Rule: quantityOnHand can never be negative.
// expiryDate is optional and defaults to nil, so existing call sites that don't set it
// (SampleKitchenData, RecordHouseholdIngredientUseCase, tests) keep compiling unchanged.
// TrackIngredientExpiryUseCase is what actually sets it.
struct HouseholdIngredient: Identifiable, Equatable, Codable {
    let id: IngredientIdentifier
    var name: String
    var quantityOnHand: Quantity
    var expiryDate: Date? = nil
    var updatedAt: Date

    // Normalised for matching against a recipe's ingredient requirements.
    var normalizedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
