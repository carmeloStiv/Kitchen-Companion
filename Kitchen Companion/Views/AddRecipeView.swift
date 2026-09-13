//
//  AddRecipeView.swift
//  Kitchen Companion
//
//  Created by Carmelo Stivala on 12/9/2026.
//

import SwiftUI

// Creates a recipe from scratch, or reviews a draft parsed from a video.
struct AddRecipeView: View {
    @ObservedObject var viewModel: KitchenViewModel
    let draft: RecipeDraft?
    @Environment(\.dismiss) private var dismiss

    @State private var title: String
    @State private var ingredients: [RecipeIngredientRequirement]
    @State private var steps: [RecipeStep]
    @FocusState private var isTitleFocused: Bool

    private let source: RecipeSource

    init(viewModel: KitchenViewModel, draft: RecipeDraft?, source: RecipeSource = .manualEntry) {
        self.viewModel = viewModel
        self.draft = draft
        self.source = source
        _title = State(initialValue: draft?.title ?? "")
        _ingredients = State(initialValue: draft?.ingredients ?? [])
        _steps = State(initialValue: draft?.steps ?? [])
    }

    var body: some View {
        NavigationStack {
            Form {
                if draft != nil {
                    Section {
                        Label("This was drafted from a video transcript. Check every ingredient and step before saving.", systemImage: "wand.and.stars")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Recipe") {
                    TextField("Recipe title", text: $title)
                        .focused($isTitleFocused)
                }

                Section("Ingredients") {
                    ForEach($ingredients) { $requirement in
                        IngredientRequirementRow(requirement: $requirement)
                    }
                    .onDelete { ingredients.remove(atOffsets: $0) }

                    Button {
                        ingredients.append(RecipeIngredientRequirement(id: UUID().uuidString, ingredientName: "", requiredQuantity: Quantity(amount: 0, unit: .grams)))
                    } label: {
                        Label("Add Ingredient", systemImage: "plus")
                    }
                }

                Section("Steps") {
                    ForEach($steps) { $step in
                        StepRow(step: $step)
                    }
                    .onDelete { steps.remove(atOffsets: $0) }

                    Button {
                        steps.append(RecipeStep(id: UUID().uuidString, instruction: "", durationSeconds: nil, temperatureCelsius: nil))
                    } label: {
                        Label("Add Step", systemImage: "plus")
                    }
                }
            }
            .navigationTitle(draft == nil ? "New Recipe" : "Review Draft")
            .onAppear { if draft == nil { isTitleFocused = true } }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if viewModel.addRecipe(title: title, ingredients: ingredients, steps: steps, source: source) {
                            dismiss()
                        }
                    }
                }
            }
            .alert("Can't Save Recipe", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { _ in viewModel.errorMessage = nil }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
}

private struct IngredientRequirementRow: View {
    @Binding var requirement: RecipeIngredientRequirement

    var body: some View {
        HStack {
            TextField("Ingredient", text: $requirement.ingredientName)
            TextField("Amount", value: $requirement.requiredQuantity.amount, format: .number)
                .keyboardType(.decimalPad)
                .frame(width: 60)
            Picker("Unit", selection: $requirement.requiredQuantity.unit) {
                ForEach(UnitOfMeasure.allCases, id: \.self) { unit in
                    Text(unit.displayName).tag(unit)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
        }
    }
}

private struct StepRow: View {
    @Binding var step: RecipeStep

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            TextField("Instruction", text: $step.instruction, axis: .vertical)
            HStack {
                Stepper(
                    "Timer: \(step.durationSeconds.map { "\($0 / 60) min" } ?? "None")",
                    value: Binding(
                        get: { (step.durationSeconds ?? 0) / 60 },
                        set: { step.durationSeconds = $0 == 0 ? nil : $0 * 60 }
                    ),
                    in: 0...60
                )
            }
            .font(.caption)
            HStack {
                Stepper(
                    "Temp: \(step.temperatureCelsius.map { "\($0)°C" } ?? "None")",
                    value: Binding(
                        get: { step.temperatureCelsius ?? 0 },
                        set: { step.temperatureCelsius = $0 == 0 ? nil : $0 }
                    ),
                    in: 0...300,
                    step: 5
                )
            }
            .font(.caption)
        }
    }
}

#Preview {
    AddRecipeView(viewModel: KitchenViewModel(), draft: nil)
}
