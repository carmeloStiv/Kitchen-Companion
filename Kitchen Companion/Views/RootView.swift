//
//  RootView.swift
//  Kitchen Companion
//
//  Created by Carmelo Stivala on 12/9/2026.
//

import SwiftUI

// Root view - switches between the Ingredients, Recipes and Shopping List tabs.
struct RootView: View {
    @StateObject private var viewModel = KitchenViewModel()

    var body: some View {
        TabView {
            IngredientInventoryView(viewModel: viewModel)
                .tabItem { Label("Ingredients", systemImage: "carrot.fill") }

            RecipeListView(viewModel: viewModel)
                .tabItem { Label("Recipes", systemImage: "book.closed.fill") }

            ShoppingListView(viewModel: viewModel)
                .tabItem { Label("Shopping List", systemImage: "cart.fill") }
        }
        .tint(.accentColor)
    }
}

#Preview {
    RootView()
}
