//
//  UserNotificationExpiryReminderScheduler.swift
//  Kitchen Companion
//
//  Created by Carmelo Stivala on 2/10/2026.
//

import Foundation
import UserNotifications

// Schedules the "use it up" reminders as local notifications.
// The category identifier below must match the one listed in the
// notification content extension's Info.plist, that is what makes iOS show
// the custom reminder view instead of the plain banner. The ingredient
// details travel inside the notification itself (userInfo), so the
// extension does not need to open the pantry store.
final class UserNotificationExpiryReminderScheduler: NSObject, ExpiryReminderScheduling, UNUserNotificationCenterDelegate {
    static let categoryIdentifier = "EXPIRING_INGREDIENT"

    private let center: UNUserNotificationCenter
    private let defaults: UserDefaults
    private static let scheduledKeysDefaultsKey = "scheduledExpiryReminderKeys"

    init(center: UNUserNotificationCenter = .current(), defaults: UserDefaults = .standard) {
        self.center = center
        self.defaults = defaults
        super.init()
        center.delegate = self
        center.setNotificationCategories([
            UNNotificationCategory(
                identifier: Self.categoryIdentifier,
                actions: [],
                intentIdentifiers: []
            )
        ])
        center.requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    // The app plans reminders again on every launch and every save. Remembering
    // which ingredient and use-by date pairs already have one stops the same
    // reminder firing over and over. Changing the use-by date makes a new pair.
    func scheduleReminder(for ingredient: HouseholdIngredient, at fireDate: Date) {
        let key = "\(ingredient.id.rawValue)-\(ingredient.expiryDate?.timeIntervalSince1970 ?? 0)"
        var scheduledKeys = Set(defaults.stringArray(forKey: Self.scheduledKeysDefaultsKey) ?? [])
        guard !scheduledKeys.contains(key) else { return }
        scheduledKeys.insert(key)
        defaults.set(Array(scheduledKeys), forKey: Self.scheduledKeysDefaultsKey)

        let content = UNMutableNotificationContent()
        content.title = "\(ingredient.name) is expiring soon"
        content.body = "Use it up before it goes off."
        content.sound = .default
        content.categoryIdentifier = Self.categoryIdentifier
        content.userInfo = [
            "ingredientName": ingredient.name,
            "quantityText": ingredient.quantityOnHand.displayText,
            "expiryDate": ingredient.expiryDate?.timeIntervalSince1970 ?? 0
        ]

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: fireDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: Self.requestIdentifier(for: ingredient.id),
            content: content,
            trigger: trigger
        )
        center.add(request)
    }

    func cancelReminder(forIngredientID ingredientID: IngredientIdentifier) {
        center.removePendingNotificationRequests(withIdentifiers: [Self.requestIdentifier(for: ingredientID)])
    }

    // Lets the reminder show as a banner even while the app is open.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }

    private static func requestIdentifier(for ingredientID: IngredientIdentifier) -> String {
        "expiry-reminder-\(ingredientID.rawValue)"
    }
}

// Used when reminders should stay silent, for example in UI tests.
struct SilentExpiryReminderScheduler: ExpiryReminderScheduling {
    func scheduleReminder(for ingredient: HouseholdIngredient, at fireDate: Date) {}
    func cancelReminder(forIngredientID ingredientID: IngredientIdentifier) {}
}
