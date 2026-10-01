//
//  IngredientRecord.swift
//  Kitchen Companion
//
//  Created by Carmelo Stivala on 29/9/2026.
//

import Foundation
import SwiftData

// SwiftData model for one ingredient the household has on hand.
// This is the persisted counterpart to HouseholdIngredient. The repository
// (SwiftDataIngredientPantry) is the only place that converts between the two,
// so the rest of the app keeps working with plain HouseholdIngredient values.
@Model
final class IngredientRecord {
    @Attribute(.unique) var id: String
    var name: String
    var quantityAmount: Double
    var quantityUnit: String
    var expiryDate: Date?
    var updatedAt: Date

    // Inverse of ShoppingListItemRecord.relatedIngredient. Nullify rather than
    // cascade, because deleting an ingredient from the pantry should not
    // delete a shopping list item that references it, it should just clear
    // the link.
    @Relationship(deleteRule: .nullify, inverse: \ShoppingListItemRecord.relatedIngredient)
    var shoppingListItems: [ShoppingListItemRecord]

    init(id: String, name: String, quantityAmount: Double, quantityUnit: String, expiryDate: Date?, updatedAt: Date) {
        self.id = id
        self.name = name
        self.quantityAmount = quantityAmount
        self.quantityUnit = quantityUnit
        self.expiryDate = expiryDate
        self.updatedAt = updatedAt
        self.shoppingListItems = []
    }
}
