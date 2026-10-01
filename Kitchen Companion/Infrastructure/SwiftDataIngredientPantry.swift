//
//  SwiftDataIngredientPantry.swift
//  Kitchen Companion
//
//  Created by Carmelo Stivala on 29/9/2026.
//

import Foundation
import SwiftData

// SwiftData backed implementation of IngredientPantry.
// Converts between the persisted IngredientRecord and the plain
// HouseholdIngredient the rest of the app already works with.
final class SwiftDataIngredientPantry: IngredientPantry {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func allIngredients() -> [HouseholdIngredient] {
        let descriptor = FetchDescriptor<IngredientRecord>(sortBy: [SortDescriptor(\.name)])
        let records = (try? context.fetch(descriptor)) ?? []
        return records.map(Self.toDomain)
    }

    func ingredient(named name: String) -> HouseholdIngredient? {
        let normalized = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return allIngredients().first { $0.normalizedName == normalized }
    }

    func save(ingredient: HouseholdIngredient) {
        let targetID = ingredient.id.rawValue
        let descriptor = FetchDescriptor<IngredientRecord>(predicate: #Predicate { $0.id == targetID })
        if let existing = try? context.fetch(descriptor).first {
            existing.name = ingredient.name
            existing.quantityAmount = ingredient.quantityOnHand.amount
            existing.quantityUnit = ingredient.quantityOnHand.unit.rawValue
            existing.expiryDate = ingredient.expiryDate
            existing.updatedAt = ingredient.updatedAt
        } else {
            let record = IngredientRecord(
                id: targetID,
                name: ingredient.name,
                quantityAmount: ingredient.quantityOnHand.amount,
                quantityUnit: ingredient.quantityOnHand.unit.rawValue,
                expiryDate: ingredient.expiryDate,
                updatedAt: ingredient.updatedAt
            )
            context.insert(record)
        }
        try? context.save()
    }

    // Predicate driven query used by the Expiring Soon screen and the
    // widget/notification extension. Fetches everything with a non nil
    // expiry date and filters in plain Swift, rather than trying to force
    // unwrap an optional inside a #Predicate, which is not reliably
    // supported by the macro.
    func ingredientsExpiring(within days: Int, of referenceDate: Date) -> [HouseholdIngredient] {
        let cutoff = Calendar.current.date(byAdding: .day, value: days, to: referenceDate) ?? referenceDate
        let descriptor = FetchDescriptor<IngredientRecord>(
            predicate: #Predicate { $0.expiryDate != nil }
        )
        let records = (try? context.fetch(descriptor)) ?? []
        return records
            .filter { record in
                guard let expiryDate = record.expiryDate else { return false }
                return expiryDate <= cutoff
            }
            .map(Self.toDomain)
    }

    private static func toDomain(_ record: IngredientRecord) -> HouseholdIngredient {
        HouseholdIngredient(
            id: IngredientIdentifier(rawValue: record.id),
            name: record.name,
            quantityOnHand: Quantity(amount: record.quantityAmount, unit: UnitOfMeasure(rawValue: record.quantityUnit) ?? .pieces),
            expiryDate: record.expiryDate,
            updatedAt: record.updatedAt
        )
    }
}
