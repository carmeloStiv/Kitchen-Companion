# Kitchen Companion

Kitchen Companion is an iOS MVP built to help a home cook answer one simple but important question before they start cooking: do I actually have what this recipe needs?

## Domain context

The stakeholder is a home cook who keeps a pantry and a small collection of recipes. Recipes get collected from all over the place, memory, a cooking video, a handwritten note, but nothing ever checks them against what's actually in the kitchen. Usually the cook finds out they're missing an ingredient halfway through cooking, once it's too late to do much about it. Kitchen Companion moves that check earlier, before the cook starts, and also lets them turn a recipe video into a recipe instead of typing it all out by hand.

A few rules the app enforces because of this:

- A recipe needs a title, at least one ingredient, and at least one step before it can be saved.
- An ingredient's required quantity has to be more than zero.
- Stock in the pantry can never go negative.
- A recipe only counts as "ready to cook" when every ingredient it needs is on hand in a matching unit and a sufficient amount. If the units don't match (say the recipe wants grams but the pantry has it recorded in pieces), the app doesn't guess, it flags it as something the cook needs to check themselves.

## Screens

| Screen | What it's for |
|---|---|
| Ingredient Inventory | See what's currently in the pantry |
| Add / Update Ingredient | Record what's on hand and how much |
| Recipe List | Browse saved recipes with a quick "ready to cook" status |
| Recipe Detail | Check a recipe's ingredients against the pantry, follow the steps, run step timers |
| Add Recipe | Type in a recipe's title, ingredients, and steps |
| Import Recipe from Video | Turn a video transcript into a recipe draft instead of typing it manually |

## Architecture

The app is split into layers, and each layer only knows about the one below it:

```
SwiftUI Views
    (IngredientInventoryView, RecipeListView, RecipeDetailView, ...)
        |
ViewModels (MVVM)
    (KitchenViewModel, VideoImportViewModel)
        |
Use Case Layer   <- business rules live here, not in Views or ViewModels
    (RecordHouseholdIngredientUseCase,
     AddRecipeUseCase,
     CheckRecipeFeasibilityUseCase)
        |
Domain Models + Repository Protocols
    (HouseholdIngredient, Recipe, Quantity, IngredientPantry, RecipeBook)
        |
Infrastructure
    (LocalKitchenStore, RecipeDraftParser, VideoRecipeTranscriber)
```

These three use cases were chosen because they cover the points in the workflow where a mistake actually matters: recording stock wrong, saving a recipe that can't really be followed, and telling a cook a recipe is ready when it isn't. Each one returns a typed `Result` with its own `Failure` enum (things like `.ingredientQuantityNotPositive` or `.noStepsListed`), and the error messages are written for the cook using the app, not for a developer reading a log.

Project layout:

```
Kitchen Companion/
├── Domain/         core types and repository protocols
├── UseCases/        business operations, one struct per operation
├── Infrastructure/   storage, parsing, and transcription
├── ViewModels/       state that binds Use Cases to Views
└── Views/            SwiftUI screens
```

## Testing

Unit tests live in `Kitchen CompanionTests` and cover all three use cases' happy paths, boundary conditions, and failure cases, with test names written in plain domain terms (e.g. `test_addRecipe_fails_whenAnIngredientQuantityIsZero`). UI tests live in `Kitchen CompanionUITests` and run through the app end to end in the simulator.

To run everything, open the project in Xcode and press `Cmd+U` with the Kitchen Companion scheme selected. Or from the command line:

```bash
xcodebuild test -project "Kitchen Companion.xcodeproj" -scheme "Kitchen Companion" -destination 'platform=iOS Simulator,name=iPhone 17'
```

## Setup

1. Open `Kitchen Companion.xcodeproj` in Xcode (26 or later).
2. Select the Kitchen Companion scheme and an iOS 26.5+ simulator.
3. Build and run (`Cmd+R`). The app starts pre-loaded with some sample pantry stock and one sample recipe, so the feasibility check has something to compare against right away.

There are no external dependencies to install. Everything runs on local, in-memory sample data.
