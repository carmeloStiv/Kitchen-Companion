//
//  RecipeListView.swift
//  Kitchen Companion
//
//  Created by Carmelo Stivala on 12/9/2026.
//

import SwiftUI

// The household's recipe box, with a feasibility badge on each recipe.
struct RecipeListView: View {
    @ObservedObject var viewModel: KitchenViewModel
    @State private var isAddingRecipe = false
    @State private var isImportingFromVideo = false

    var body: some View {
        NavigationStack {
            List(viewModel.recipes) { recipe in
                NavigationLink {
                    RecipeDetailView(viewModel: viewModel, recipe: recipe)
                } label: {
                    RecipeRow(recipe: recipe, feasibility: viewModel.feasibility(for: recipe))
                }
            }
            .navigationTitle("Recipes")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        isImportingFromVideo = true
                    } label: {
                        Label("Import from Video", systemImage: "video.badge.plus")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isAddingRecipe = true
                    } label: {
                        Image(systemName: "plus.circle.fill").font(.title2)
                    }
                    .accessibilityLabel("Add Recipe")
                }
            }
            .sheet(isPresented: $isAddingRecipe) {
                AddRecipeView(viewModel: viewModel, draft: nil)
            }
            .sheet(isPresented: $isImportingFromVideo) {
                ImportRecipeFromVideoView(kitchenViewModel: viewModel)
            }
        }
    }
}

private struct RecipeRow: View {
    let recipe: Recipe
    let feasibility: RecipeFeasibilityReport

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(recipe.title).font(.headline)
            Text(recipe.source.displayText)
                .font(.caption)
                .foregroundStyle(.secondary)
            statusBadge
        }
    }

    private var statusBadge: some View {
        Group {
            if feasibility.canBeMadeNow {
                Label("Ready to Cook", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            } else {
                Label("Missing \(feasibility.shortfalls.count) ingredient\(feasibility.shortfalls.count == 1 ? "" : "s")", systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
            }
        }
        .font(.caption.weight(.semibold))
    }
}

#Preview {
    RecipeListView(viewModel: KitchenViewModel())
}
