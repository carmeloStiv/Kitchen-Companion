//
//  RecipeDraftParser.swift
//  Kitchen Companion
//
//  Created by Carmelo Stivala on 12/9/2026.
//

import Foundation

// An unsaved recipe pulled from a video transcript, shown for review before saving.
struct RecipeDraft {
    var title: String
    var ingredients: [RecipeIngredientRequirement]
    var steps: [RecipeStep]
}

// Best-effort heuristic: turns transcript text into a rough recipe draft.
enum RecipeDraftParser {
    private static let unitPatterns: [(pattern: String, unit: UnitOfMeasure)] = [
        ("g|gram|grams", .grams),
        ("kg|kilogram|kilograms", .kilograms),
        ("ml|milliliter|milliliters|millilitre|millilitres", .milliliters),
        ("l|liter|liters|litre|litres", .liters),
        ("tsp|teaspoon|teaspoons", .teaspoons),
        ("tbsp|tablespoon|tablespoons", .tablespoons),
        ("cup|cups", .cups),
        ("piece|pieces", .pieces)
    ]

    static func parse(transcript: String, suggestedTitle: String) -> RecipeDraft {
        let lines = transcript
            .components(separatedBy: .newlines)
            .flatMap { $0.components(separatedBy: ". ") }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        var ingredients: [RecipeIngredientRequirement] = []
        var steps: [RecipeStep] = []

        for line in lines {
            if let requirement = parseIngredientLine(line) {
                ingredients.append(requirement)
            } else {
                steps.append(RecipeStep(id: UUID().uuidString, instruction: line, durationSeconds: nil, temperatureCelsius: nil))
            }
        }

        return RecipeDraft(title: suggestedTitle, ingredients: ingredients, steps: steps)
    }

    // Matches a line like "2 cups flour" into a quantity + ingredient name.
    private static func parseIngredientLine(_ line: String) -> RecipeIngredientRequirement? {
        for (unitWords, unit) in unitPatterns {
            let pattern = "^(\\d+(?:\\.\\d+)?)\\s*(?:\(unitWords))\\b\\s+(?:of\\s+)?(.+)$"
            guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else { continue }
            let range = NSRange(line.startIndex..<line.endIndex, in: line)
            guard let match = regex.firstMatch(in: line, options: [], range: range) else { continue }

            guard let amountRange = Range(match.range(at: 1), in: line),
                  let nameRange = Range(match.range(at: 2), in: line),
                  let amount = Double(line[amountRange]) else { continue }

            let name = String(line[nameRange]).trimmingCharacters(in: .whitespacesAndNewlines)
            guard !name.isEmpty else { continue }

            return RecipeIngredientRequirement(
                id: UUID().uuidString,
                ingredientName: name.capitalized,
                requiredQuantity: Quantity(amount: amount, unit: unit)
            )
        }
        return nil
    }
}
