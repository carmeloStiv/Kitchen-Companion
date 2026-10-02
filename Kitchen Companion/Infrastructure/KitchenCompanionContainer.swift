//
//  KitchenCompanionContainer.swift
//  Kitchen Companion
//
//  Created by Carmelo Stivala on 29/9/2026.
//

import Foundation
import SwiftData

// Builds the single shared ModelContainer for the app. Kept in one place so
// the schema is only listed once, and stored in the App Group container so
// the widget and notification extension read and write the same pantry
// and shopping list the main app does, not a separate empty copy.
enum KitchenCompanionContainer {
    static let appGroupIdentifier = "group.com.CarmeloS.KitchenCompanion"

    static let shared: ModelContainer = makeShared()

    static func makeShared() -> ModelContainer {
        let schema = Schema([
            IngredientRecord.self,
            ShoppingListItemRecord.self
        ])
        let configuration = ModelConfiguration(
            schema: schema,
            groupContainer: .identifier(appGroupIdentifier)
        )
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create the SwiftData model container: \(error)")
        }
    }
}
