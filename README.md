# Kitchen Companion

Kitchen Companion is an iOS app that helps a household cook what they already have and waste less food. It tracks what is in the pantry and when each item needs using by, checks saved recipes against that stock, and warns the household before food goes off, on the Home Screen and through notifications.

## Domain context

The stakeholder is a home cook who looks after a household pantry. Food gets thrown out because nobody remembers what is in the cupboard or when it expires, and the cook often finds out an ingredient is missing only once they have started cooking. The app answers two questions: what do I have that needs using up soon, and can I make this recipe right now?

Rules the app enforces:

- A recipe needs a title, at least one ingredient and at least one step.
- Stock on hand can never be negative.
- A use-by date cannot be in the past when it is set.
- A recipe is only "ready to cook" when every ingredient is on hand in a matching unit and a big enough amount. The app never guesses between units (grams against pieces), it flags the mismatch instead.
- A shopping list item is never duplicated while it is still pending.

## Screens

| Screen | What it's for |
|---|---|
| My Ingredients | See the pantry, with use-by dates |
| Add Ingredient | Record an ingredient, its amount and its use-by date |
| Ingredient detail | Edit an amount or use-by date, or remove it from the pantry |
| Recipes | Browse recipes with a "ready to cook" status |
| Recipe detail | Check ingredients against the pantry, follow steps, run timers |
| Add Recipe | Type in a recipe |
| Import Recipe from Video | Draft a recipe from a cooking video's speech |

## System extensions

| Extension | The situation it solves |
|---|---|
| Expiring Soon widget (small and medium) | The cook is in the kitchen deciding what to make and wants to see what needs using up, without opening the app. |
| Notification content extension | A reminder arrives a week before an ingredient's use-by date. Expanding it shows a card with the ingredient, how much is left and how many days remain, so the cook can decide what to do straight away. |

Both read the same data the app writes. The app reloads the widget after every ingredient change.

**App Group identifier:** `group.com.CarmeloS.KitchenCompanion`

## Database

The app uses SwiftData, stored in the App Group container so the app and the widget see the same pantry. SwiftData runs on top of Core Data's storage engine. It was chosen because the data is private to one household and needs fast local reads from the widget, with no account or sync.

- Two related record types: `IngredientRecord` and `ShoppingListItemRecord`. A shopping list item can link back to the pantry ingredient it became once bought.
- A real domain query: `ingredientsExpiring(within:of:)` fetches ingredients that have a use-by date and keeps those inside the warning window (7 days).
- Views and view models never touch SwiftData. They only use the `IngredientPantry`, `RecipeBook` and `ShoppingListRepository` protocols, so tests swap in mocks.

Recipes are still held in memory and reset when the app restarts.

## Architecture

```
SwiftUI Views
    |
ViewModels (MVVM)
    |
Use Cases           <- business rules live here
    |
Domain models + repository protocols
    |
Infrastructure      <- SwiftData repositories, notification scheduler, parsers
```

The widget and notification extension reuse the same use cases and domain types as the app. The widget calls `CheckExpiringIngredientsUseCase` directly against the shared store.

Use cases (each has its own typed error enum with messages written for the cook):

- `RecordHouseholdIngredientUseCase`, `DeleteHouseholdIngredientUseCase`
- `TrackIngredientExpiryUseCase`, `CheckExpiringIngredientsUseCase`, `PlanExpiryReminderUseCase`
- `AddRecipeUseCase`, `CheckRecipeFeasibilityUseCase`
- `GenerateShoppingListUseCase`, `MarkShoppingItemPurchasedUseCase`

```
Kitchen Companion/   app: Domain, UseCases, Infrastructure, ViewModels, Views
KitchenWidget/       Expiring Soon widget
KitchenNotification/ notification content extension
```

## Testing

There are 46 unit tests across the use cases, written against test doubles instead of the real database, with names that describe the scenario (for example `test_generateShoppingListItem_fails_whenIngredientAlreadyPendingOnList`). There are also 3 UI tests that drive the app in the simulator.

Run everything with Cmd+U, or:

```bash
xcodebuild test -project "Kitchen Companion.xcodeproj" -scheme "Kitchen Companion" -destination 'platform=iOS Simulator,name=iPhone 17'
```

## Setup

1. Open `Kitchen Companion.xcodeproj` in Xcode 26 or later.
2. Select the **Kitchen Companion** scheme and an iOS 26.5 simulator, then run it. Run this scheme, not the widget one, so the app seeds its sample pantry.
3. Allow notifications when asked.
4. To see the widget, long-press the Home Screen, tap +, and add Expiring Soon.
5. To see a reminder, open an ingredient, turn on a use-by date within the next week and save. A banner arrives within a few seconds, and long-pressing it opens the card.

Signing is automatic with a personal team. A provisioning warning about devices can be ignored for simulator use.

## Git workflow

Work was done on feature branches and merged into `main` once stable, with Conventional Commits (`feat:`, `fix:`, `test:`, `docs:`).
