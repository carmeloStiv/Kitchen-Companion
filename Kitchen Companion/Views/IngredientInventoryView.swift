//
//  IngredientInventoryView.swift
//  Kitchen Companion
//
//  Created by Carmelo Stivala on 12/9/2026.
//

import SwiftUI

// Shows everything the household currently has on hand.
struct IngredientInventoryView: View {
    @ObservedObject var viewModel: KitchenViewModel
    @State private var isAddingIngredient = false

    var body: some View {
        NavigationStack {
            List(viewModel.ingredients) { ingredient in
                NavigationLink {
                    IngredientDetailView(viewModel: viewModel, ingredient: ingredient)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(ingredient.name).font(.headline)
                            if let expiryDate = ingredient.expiryDate {
                                Text("Use by \(expiryDate.formatted(date: .abbreviated, time: .omitted))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                        Text(ingredient.quantityOnHand.displayText)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("My Ingredients")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isAddingIngredient = true
                    } label: {
                        Image(systemName: "plus.circle.fill").font(.title2)
                    }
                    .accessibilityLabel("Add Ingredient")
                }
            }
            .sheet(isPresented: $isAddingIngredient) {
                AddIngredientView(viewModel: viewModel)
            }
        }
    }
}

#Preview {
    IngredientInventoryView(viewModel: KitchenViewModel())
}
