//
//  AddShoppingItemView.swift
//  Kitchen Companion
//
//  Created by Carmelo Stivala on 3/10/2026.
//

import SwiftUI

// Adds something the household wants to buy.
struct AddShoppingItemView: View {
    @ObservedObject var viewModel: KitchenViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var amount = ""
    @State private var unit: UnitOfMeasure = .pieces
    @FocusState private var isNameFocused: Bool

    var body: some View {
        NavigationStack {
            Form {
                TextField("What do you need to buy?", text: $name)
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
            .navigationTitle("Add Shopping Item")
            .onAppear { isNameFocused = true }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let quantity = Quantity(amount: Double(amount) ?? 0, unit: unit)
                        if viewModel.addShoppingItem(name: name, quantity: quantity) {
                            dismiss()
                        }
                    }
                }
            }
            .alert("Can't Add Item", isPresented: Binding(
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
    AddShoppingItemView(viewModel: KitchenViewModel())
}
