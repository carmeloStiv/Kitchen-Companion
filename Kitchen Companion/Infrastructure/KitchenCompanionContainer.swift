//
//  KitchenCompanionContainer.swift
//  Kitchen Companion
//
//  Created by Carmelo Stivala on 29/9/2026.
//

import Foundation
import SwiftData

// Builds the single shared ModelContainer for the app. Kept in one place so
// the schema is only listed once, and so the widget/notification extension
// can later build a matching container pointed at the same App Group store.
enum KitchenCompanionContainer {
    static func makeShared() -> ModelContainer {
        let schema = Schema([
            IngredientRecord.self,
            ShoppingListItemRecord.self
        ])
        let configuration = ModelConfiguration(schema: schema)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create the SwiftData model container: \(error)")
        }
    }
}
