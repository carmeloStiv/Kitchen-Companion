//
//  Identifiers.swift
//  Kitchen Companion
//
//  Created by Carmelo Stivala on 12/9/2026.
//

import Foundation

/// Uniquely identifies an ingredient in a household's kitchen inventory.
struct IngredientIdentifier: Hashable, Codable, CustomStringConvertible {
    let rawValue: String
    var description: String { rawValue }
}

/// Uniquely identifies a recipe, manual or video-imported.
struct RecipeIdentifier: Hashable, Codable, CustomStringConvertible {
    let rawValue: String
    var description: String { rawValue }
}
