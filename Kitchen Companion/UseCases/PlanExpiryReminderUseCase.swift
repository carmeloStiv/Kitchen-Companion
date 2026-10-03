//
//  PlanExpiryReminderUseCase.swift
//  Kitchen Companion
//
//  Created by Carmelo Stivala on 2/10/2026.
//

import Foundation

// Works out when to remind the household about an ingredient that is
// about to expire. The reminder goes out at 9am a week before the use-by
// date, which gives the household time to plan meals around it. If that
// moment has already passed but the ingredient has not expired yet, the
// reminder goes out straight away, because there is still time to use it up.
struct PlanExpiryReminderUseCase {
    enum Failure: LocalizedError, Equatable {
        case noExpiryDate(ingredientName: String)
        case alreadyExpired(ingredientName: String)

        var errorDescription: String? {
            switch self {
            case .noExpiryDate(let ingredientName):
                return "\"\(ingredientName)\" has no use-by date, so there is nothing to remind you about. Add a date to get a reminder."
            case .alreadyExpired(let ingredientName):
                return "\"\(ingredientName)\" is already past its use-by date. Check it before using it, and remove it from your pantry if it has gone off."
            }
        }
    }

    static let reminderHour = 9
    static let immediateReminderDelaySeconds: TimeInterval = 5

    func execute(ingredient: HouseholdIngredient, now: Date = Date()) -> Result<Date, Failure> {
        guard let expiryDate = ingredient.expiryDate else {
            return .failure(.noExpiryDate(ingredientName: ingredient.name))
        }
        guard expiryDate >= now else {
            return .failure(.alreadyExpired(ingredientName: ingredient.name))
        }

        let calendar = Calendar.current
        let warningDay = calendar.date(
            byAdding: .day, value: -CheckExpiringIngredientsUseCase.warningWindowDays, to: expiryDate
        ) ?? expiryDate
        let usualReminder = calendar.date(
            bySettingHour: Self.reminderHour, minute: 0, second: 0, of: warningDay
        ) ?? warningDay

        if usualReminder > now {
            return .success(usualReminder)
        }
        return .success(now.addingTimeInterval(Self.immediateReminderDelaySeconds))
    }
}
