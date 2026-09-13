//
//  RecipeDetailView.swift
//  Kitchen Companion
//
//  Created by Carmelo Stivala on 12/9/2026.
//

import SwiftUI

// Shows ingredient status and each step with its own timer and temperature.
struct RecipeDetailView: View {
    @ObservedObject var viewModel: KitchenViewModel
    let recipe: Recipe

    var body: some View {
        List {
            Section("Ingredients") {
                let shortfallsByRequirement = Dictionary(
                    uniqueKeysWithValues: viewModel.feasibility(for: recipe).shortfalls.map { ($0.requirement.id, $0) }
                )
                ForEach(recipe.ingredients) { requirement in
                    IngredientRequirementStatusRow(requirement: requirement, shortfall: shortfallsByRequirement[requirement.id])
                }
            }

            Section("Method") {
                ForEach(recipe.steps) { step in
                    StepTimerRow(step: step)
                }
            }
        }
        .navigationTitle(recipe.title)
    }
}

private struct IngredientRequirementStatusRow: View {
    let requirement: RecipeIngredientRequirement
    let shortfall: IngredientShortfall?

    var body: some View {
        HStack {
            Image(systemName: shortfall == nil ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(shortfall == nil ? .green : .red)
            VStack(alignment: .leading, spacing: 2) {
                Text("\(requirement.requiredQuantity.displayText) \(requirement.ingredientName)")
                if let shortfall {
                    Text(shortfallDescription(shortfall))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func shortfallDescription(_ shortfall: IngredientShortfall) -> String {
        switch shortfall.reason {
        case .missingEntirely:
            return "Not in your ingredients"
        case .insufficientQuantity(let have):
            return "Only have \(have.displayText)"
        case .unitMismatch(let have):
            return "Have \(have.displayText) - can't compare units"
        }
    }
}

private struct StepTimerRow: View {
    let step: RecipeStep
    @State private var timerEndDate: Date?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(step.instruction)

            HStack(spacing: 16) {
                if let temperature = step.temperatureCelsius {
                    Label("\(temperature)°C", systemImage: "thermometer.medium")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.orange)
                }

                if let duration = step.durationSeconds {
                    timerControl(duration: duration)
                }
            }
        }
        .padding(.vertical, 4)
    }

    // TimelineView recomputes the label from the end date every second.
    @ViewBuilder
    private func timerControl(duration: Int) -> some View {
        if let timerEndDate {
            TimelineView(.periodic(from: .now, by: 1)) { context in
                let remaining = max(0, Int(timerEndDate.timeIntervalSince(context.date).rounded(.up)))
                Text(formatted(remaining))
                    .font(.caption.weight(.semibold).monospacedDigit())
                    .foregroundStyle(remaining == 0 ? .green : .accentColor)
            }
        } else {
            Button {
                timerEndDate = Date().addingTimeInterval(TimeInterval(duration))
            } label: {
                Label("Start \(duration / 60)-Minute Timer", systemImage: "timer")
            }
            .font(.caption.weight(.semibold))
            .buttonStyle(.bordered)
        }
    }

    private func formatted(_ seconds: Int) -> String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
}

#Preview {
    NavigationStack {
        RecipeDetailView(viewModel: KitchenViewModel(), recipe: SampleKitchenData.recipes[0])
    }
}
