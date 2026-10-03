//
//  AddIngredientView.swift
//  Kitchen Companion
//
//  Created by Carmelo Stivala on 12/9/2026.
//

import SwiftUI

// Records an ingredient; saving an existing name updates its quantity and use-by date.
struct AddIngredientView: View {
    @ObservedObject var viewModel: KitchenViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var amount = ""
    @State private var unit: UnitOfMeasure = .grams
    @State private var hasExpiryDate = false
    @State private var expiryDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
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
                Section("Use-by date") {
                    Toggle("Has a use-by date", isOn: $hasExpiryDate)
                    if hasExpiryDate {
                        DatePicker("Use by", selection: $expiryDate, displayedComponents: .date)
                    }
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
                        if viewModel.recordIngredient(name: name, quantity: quantity, expiryDate: hasExpiryDate ? expiryDate : nil) {
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
