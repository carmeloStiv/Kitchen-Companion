//
//  KitchenWidget.swift
//  KitchenWidget
//
//  Created by Carmelo Stivala on 2/10/2026.
//

import WidgetKit
import SwiftData
import SwiftUI

// Shows the household which pantry ingredients are expiring soonest, so they
// can check it from the Home Screen without opening the app, for example
// while standing in the kitchen deciding what to cook tonight.
struct ExpiringSoonProvider: TimelineProvider {
    private static let lookAheadDays = 3
    private let checkExpiringIngredientsUseCase = CheckExpiringIngredientsUseCase()

    func placeholder(in context: Context) -> ExpiringSoonEntry {
        ExpiringSoonEntry(date: Date(), expiringIngredients: [
            HouseholdIngredient(
                id: IngredientIdentifier(rawValue: "placeholder"),
                name: "Milk",
                quantityOnHand: Quantity(amount: 500, unit: .milliliters),
                expiryDate: Date(),
                updatedAt: Date()
            )
        ])
    }

    func getSnapshot(in context: Context, completion: @escaping (ExpiringSoonEntry) -> Void) {
        completion(currentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ExpiringSoonEntry>) -> Void) {
        let entry = currentEntry()
        let nextRefresh = Calendar.current.date(byAdding: .hour, value: 1, to: entry.date) ?? entry.date
        completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
    }

    private func currentEntry() -> ExpiringSoonEntry {
        let now = Date()
        let pantry = SwiftDataIngredientPantry(context: ModelContext(KitchenCompanionContainer.shared))
        let result = checkExpiringIngredientsUseCase.execute(pantry: pantry, withinDays: Self.lookAheadDays, now: now)
        let expiring = (try? result.get()) ?? []
        return ExpiringSoonEntry(date: now, expiringIngredients: expiring)
    }
}

struct ExpiringSoonEntry: TimelineEntry {
    let date: Date
    let expiringIngredients: [HouseholdIngredient]
}

struct ExpiringSoonEntryView: View {
    @Environment(\.widgetFamily) private var family
    var entry: ExpiringSoonEntry

    var body: some View {
        switch family {
        case .systemSmall:
            smallLayout
        default:
            mediumLayout
        }
    }

    private var smallLayout: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Expiring Soon")
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            if let first = entry.expiringIngredients.first {
                Text(first.name)
                    .font(.headline)
                if entry.expiringIngredients.count > 1 {
                    Text("+\(entry.expiringIngredients.count - 1) more")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            } else {
                Text("Nothing expiring")
                    .font(.headline)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var mediumLayout: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Expiring Soon")
                .font(.caption)
                .foregroundStyle(.secondary)
            if entry.expiringIngredients.isEmpty {
                Text("Nothing in your pantry is expiring soon.")
                    .font(.subheadline)
            } else {
                ForEach(entry.expiringIngredients.prefix(3)) { ingredient in
                    HStack {
                        Text(ingredient.name)
                            .font(.subheadline)
                        Spacer()
                        if let expiryDate = ingredient.expiryDate {
                            Text(expiryDate, style: .date)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct KitchenWidget: Widget {
    let kind: String = "ExpiringSoonWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ExpiringSoonProvider()) { entry in
            ExpiringSoonEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Expiring Soon")
        .description("See which pantry ingredients need using up soon.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    KitchenWidget()
} timeline: {
    ExpiringSoonEntry(date: .now, expiringIngredients: [])
}

#Preview(as: .systemMedium) {
    KitchenWidget()
} timeline: {
    ExpiringSoonEntry(date: .now, expiringIngredients: [
        HouseholdIngredient(
            id: IngredientIdentifier(rawValue: "I-1"),
            name: "Milk",
            quantityOnHand: Quantity(amount: 300, unit: .milliliters),
            expiryDate: Date(),
            updatedAt: Date()
        )
    ])
}
