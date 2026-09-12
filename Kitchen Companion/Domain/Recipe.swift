//
//  Recipe.swift
//  Kitchen Companion
//
//  Created by Carmelo Stivala on 12/9/2026.
//

import Foundation

/// One ingredient a recipe requires, independent of what the household actually has.
struct RecipeIngredientRequirement: Identifiable, Equatable, Codable {
    let id: String
    var ingredientName: String
    var requiredQuantity: Quantity
}

/// One step of a recipe's method, with an optional timer and temperature.
struct RecipeStep: Identifiable, Equatable, Codable {
    let id: String
    var instruction: String
    var durationSeconds: Int?
    var temperatureCelsius: Int?
}

/// Where a recipe's content came from - typed by hand, or drafted from a video.
enum RecipeSource: Codable, Equatable {
    case manualEntry
    case importedVideo(fileName: String)

    var displayText: String {
        switch self {
        case .manualEntry: return "Added manually"
        case .importedVideo(let fileName): return "Imported from video: \(fileName)"
        }
    }
}

/// A recipe a household can cook. Business Rule: needs at least one ingredient and one step.
struct Recipe: Identifiable, Equatable, Codable {
    let id: RecipeIdentifier
    var title: String
    var ingredients: [RecipeIngredientRequirement]
    var steps: [RecipeStep]
    var source: RecipeSource
    let createdAt: Date
}
