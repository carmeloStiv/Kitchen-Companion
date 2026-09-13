//
//  AddIngredientView.swift
//  Kitchen Companion
//
//  Created by Carmelo Stivala on 12/9/2026.
//

import SwiftUI

// Records an ingredient; saving an existing name updates its quantity.
struct AddIngredientView: View {
    @ObservedObject var viewModel: KitchenViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var amount = ""
    @State private var unit: UnitOfMeasure = .grams
    @FocusState private var isNameFocused: Bool

    var body: some View {
        NavigationStack {
            Form {
                TextField("Ingredient name", text: $name)
                    .focused($isNameFocused)
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
            .navigationTitle("Add Ingredient")
            .onAppear { isNameFocused = true }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let quantity = Quantity(amount: Double(amount) ?? 0, unit: unit)
                        if viewModel.recordIngredient(name: name, quantity: quantity) {
                            dismiss()
                        }
                    }
                }
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
    }
}

#Preview {
    AddIngredientView(viewModel: KitchenViewModel())
}
