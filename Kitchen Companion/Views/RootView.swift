//
//  RootView.swift
//  Kitchen Companion
//
//  Created by Carmelo Stivala on 12/9/2026.
//

import SwiftUI

// Root view - switches between the Ingredients and Recipes tabs.
struct RootView: View {
    @StateObject private var viewModel = KitchenViewModel()

    var body: some View {
        TabView {
            IngredientInventoryView(viewModel: viewModel)
                .tabItem { Label("Ingredients", systemImage: "carrot.fill") }

            RecipeListView(viewModel: viewModel)
                .tabItem { Label("Recipes", systemImage: "book.closed.fill") }
        }
        .tint(.accentColor)
    }
}

#Preview {
    RootView()
}
