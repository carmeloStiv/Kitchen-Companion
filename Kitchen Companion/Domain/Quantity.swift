//
//  Quantity.swift
//  Kitchen Companion
//
//  Created by Carmelo Stivala on 12/9/2026.
//

import Foundation

/// A kitchen unit of measure - units are never auto-converted between each other.
enum UnitOfMeasure: String, Codable, CaseIterable {
    case grams, kilograms, milliliters, liters, pieces, teaspoons, tablespoons, cups

    var displayName: String {
        switch self {
        case .grams: return "g"
        case .kilograms: return "kg"
        case .milliliters: return "ml"
        case .liters: return "L"
        case .pieces: return "pcs"
        case .teaspoons: return "tsp"
        case .tablespoons: return "tbsp"
        case .cups: return "cups"
        }
    }
}

/// An amount of something in a specific unit, e.g. "200 grams" or "2 cups".
struct Quantity: Equatable, Codable {
    var amount: Double
    var unit: UnitOfMeasure

    var displayText: String {
        let trimmedAmount = amount.truncatingRemainder(dividingBy: 1) == 0
            ? String(Int(amount))
            : String(format: "%.1f", amount)
        return "\(trimmedAmount) \(unit.displayName)"
    }

    /// Returns nil (not false) when units differ and can't be honestly compared.
    func covers(_ required: Quantity) -> Bool? {
        guard unit == required.unit else { return nil }
        return amount >= required.amount
    }
}
