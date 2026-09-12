//
//  SampleKitchenData.swift
//  Kitchen Companion
//
//  Created by Carmelo Stivala on 12/9/2026.
//

import Foundation

// Seed data standing in for a household's real pantry and recipe box.
enum SampleKitchenData {
    static let ingredients: [HouseholdIngredient] = [
        HouseholdIngredient(id: IngredientIdentifier(rawValue: "I-1"), name: "Plain Flour", quantityOnHand: Quantity(amount: 500, unit: .grams), updatedAt: Date()),
        HouseholdIngredient(id: IngredientIdentifier(rawValue: "I-2"), name: "Eggs", quantityOnHand: Quantity(amount: 6, unit: .pieces), updatedAt: Date()),
        HouseholdIngredient(id: IngredientIdentifier(rawValue: "I-3"), name: "Milk", quantityOnHand: Quantity(amount: 500, unit: .milliliters), updatedAt: Date()),
        HouseholdIngredient(id: IngredientIdentifier(rawValue: "I-4"), name: "Sugar", quantityOnHand: Quantity(amount: 200, unit: .grams), updatedAt: Date())
    ]

    static let recipes: [Recipe] = [
        Recipe(
            id: RecipeIdentifier(rawValue: "R-1"),
            title: "Simple Pancakes",
            ingredients: [
                RecipeIngredientRequirement(id: "RI-1", ingredientName: "Plain Flour", requiredQuantity: Quantity(amount: 200, unit: .grams)),
                RecipeIngredientRequirement(id: "RI-2", ingredientName: "Eggs", requiredQuantity: Quantity(amount: 2, unit: .pieces)),
                RecipeIngredientRequirement(id: "RI-3", ingredientName: "Milk", requiredQuantity: Quantity(amount: 300, unit: .milliliters))
            ],
            steps: [
                RecipeStep(id: "RS-1", instruction: "Whisk flour, eggs and milk together into a smooth batter.", durationSeconds: 120, temperatureCelsius: nil),
                RecipeStep(id: "RS-2", instruction: "Cook each pancake in a hot pan until bubbles form, then flip.", durationSeconds: 90, temperatureCelsius: 180)
            ],
            source: .manualEntry,
            createdAt: Date()
        )
    ]
}
