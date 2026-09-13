//
//  AddRecipeUseCaseTests.swift
//  Kitchen Companion
//
//  Created by Carmelo Stivala on 12/9/2026.
//

import XCTest
@testable import Kitchen_Companion

final class AddRecipeUseCaseTests: XCTestCase {
    private let useCase = AddRecipeUseCase()

    private let validIngredient = RecipeIngredientRequirement(id: "RI-1", ingredientName: "Flour", requiredQuantity: Quantity(amount: 200, unit: .grams))
    private let validStep = RecipeStep(id: "RS-1", instruction: "Mix everything together.", durationSeconds: 60, temperatureCelsius: nil)

    func test_addRecipe_succeeds_withTitleIngredientsAndSteps() {
        let result = useCase.execute(title: "Pancakes", ingredients: [validIngredient], steps: [validStep], source: .manualEntry)

        XCTAssertEqual(result.assertSuccess()?.title, "Pancakes")
    }

    func test_addRecipe_fails_whenTitleIsEmpty() {
        let result = useCase.execute(title: "  ", ingredients: [validIngredient], steps: [validStep], source: .manualEntry)

        XCTAssertEqual(result.assertFailure(), .titleMissing)
    }

    func test_addRecipe_fails_whenNoIngredientsListed() {
        let result = useCase.execute(title: "Pancakes", ingredients: [], steps: [validStep], source: .manualEntry)

        XCTAssertEqual(result.assertFailure(), .noIngredientsListed)
    }

    func test_addRecipe_fails_whenNoStepsListed() {
        let result = useCase.execute(title: "Pancakes", ingredients: [validIngredient], steps: [], source: .manualEntry)

        XCTAssertEqual(result.assertFailure(), .noStepsListed)
    }

    func test_addRecipe_fails_whenAnIngredientQuantityIsZero() {
        let zeroQuantityIngredient = RecipeIngredientRequirement(id: "RI-2", ingredientName: "Salt", requiredQuantity: Quantity(amount: 0, unit: .teaspoons))

        let result = useCase.execute(title: "Pancakes", ingredients: [zeroQuantityIngredient], steps: [validStep], source: .manualEntry)

        XCTAssertEqual(result.assertFailure(), .ingredientQuantityNotPositive(ingredientName: "Salt"))
    }

    func test_addRecipe_succeeds_withVideoImportedSource() {
        let result = useCase.execute(title: "Pasta", ingredients: [validIngredient], steps: [validStep], source: .importedVideo(fileName: "pasta.mp4"))

        XCTAssertEqual(result.assertSuccess()?.source, .importedVideo(fileName: "pasta.mp4"))
    }
}
