//
//  IngredientDetailView.swift
//  Kitchen Companion
//
//  Created by Carmelo Stivala on 1/10/2026.
//

import SwiftUI

// Shown when the household taps an ingredient in their inventory.
// Lets them update how much they have on hand and its use-by date, or remove it from the
// pantry entirely if they no longer keep it.
struct IngredientDetailView: View {
    @ObservedObject var viewModel: KitchenViewModel
    @Environment(\.dismiss) private var dismiss

    let ingredient: HouseholdIngredient

    @State private var name: String
    @State private var amount: String
    @State private var unit: UnitOfMeasure
    @State private var hasExpiryDate: Bool
    @State private var expiryDate: Date
    @State private var isConfirmingDelete = false

    init(viewModel: KitchenViewModel, ingredient: HouseholdIngredient) {
        self.viewModel = viewModel
        self.ingredient = ingredient
        _name = State(initialValue: ingredient.name)
        _amount = State(initialValue: Self.amountText(for: ingredient.quantityOnHand.amount))
        _unit = State(initialValue: ingredient.quantityOnHand.unit)
        _hasExpiryDate = State(initialValue: ingredient.expiryDate != nil)
        _expiryDate = State(initialValue: ingredient.expiryDate
            ?? Calendar.current.date(byAdding: .day, value: 7, to: Date())
            ?? Date())
    }

    var body: some View {
        Form {
            Section("Ingredient") {
                TextField("Ingredient name", text: $name)
                HStack {
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                    Picker("Unit", selection: $unit) {
                        ForEach(UnitOfMeasure.allCases, id: \.self) { unit in
                            Text(unit.displayName).tag(unit)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }

            Section("Use-by date") {
                Toggle("Has a use-by date", isOn: $hasExpiryDate)
                if hasExpiryDate {
                    DatePicker("Use by", selection: $expiryDate, displayedComponents: .date)
                }
            }

            Section {
                Button("Remove from Pantry", role: .destructive) {
                    isConfirmingDelete = true
                }
            }
        }
        .navigationTitle(ingredient.name)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    let quantity = Quantity(amount: Double(amount) ?? 0, unit: unit)
                    if viewModel.recordIngredient(name: name, quantity: quantity, expiryDate: hasExpiryDate ? expiryDate : nil) {
                        dismiss()
                    }
                }
            }
        }
        .confirmationDialog(
            "Remove \(ingredient.name) from your pantry?",
            isPresented: $isConfirmingDelete,
            titleVisibility: .visible
        ) {
            Button("Remove", role: .destructive) {
                if viewModel.deleteIngredient(ingredient) {
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        .alert("Can't Save Ingredient", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { _ in viewModel.errorMessage = nil }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private static func amountText(for amount: Double) -> String {
        amount.truncatingRemainder(dividingBy: 1) == 0 ? String(Int(amount)) : String(amount)
    }
}

#Preview {
    NavigationStack {
        IngredientDetailView(
            viewModel: KitchenViewModel(),
            ingredient: HouseholdIngredient(
                id: IngredientIdentifier(rawValue: "I-1"),
                name: "Plain Flour",
                quantityOnHand: Quantity(amount: 500, unit: .grams),
                updatedAt: Date()
            )
        )
    }
}
