//
//  RecipeFeasibility.swift
//  Kitchen Companion
//
//  Created by Carmelo Stivala on 12/9/2026.
//

import Foundation

/// Why a required ingredient isn't confirmed covered by the household's stock.
enum IngredientShortfallReason: Equatable {
    case missingEntirely
    case insufficientQuantity(haveQuantity: Quantity)
    case unitMismatch(haveQuantity: Quantity)
}

/// One ingredient the household is short of for a recipe.
struct IngredientShortfall: Equatable, Identifiable {
    var id: String { requirement.id }
    let requirement: RecipeIngredientRequirement
    let reason: IngredientShortfallReason
}

/// Result of checking a recipe against the household's current ingredient stock.
struct RecipeFeasibilityReport: Equatable {
    let recipeID: RecipeIdentifier
    let shortfalls: [IngredientShortfall]

    var canBeMadeNow: Bool { shortfalls.isEmpty }
}
