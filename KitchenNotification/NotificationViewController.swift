//
//  NotificationViewController.swift
//  KitchenNotification
//
//  Created by Carmelo Stivala on 3/10/2026.
//

import SwiftUI
import UIKit
import UserNotifications
import UserNotificationsUI

// Replaces the plain banner for an "ingredient is expiring" reminder with a
// card showing what is about to go off, how much the household has, and how
// long is left. The details come from the notification's userInfo, which
// the main app fills in when it schedules the reminder.
class NotificationViewController: UIViewController, UNNotificationContentExtension {
    private var hostingController: UIHostingController<ExpiringIngredientCard>?

    func didReceive(_ notification: UNNotification) {
        let userInfo = notification.request.content.userInfo
        let card = ExpiringIngredientCard(
            ingredientName: userInfo["ingredientName"] as? String ?? "An ingredient",
            quantityText: userInfo["quantityText"] as? String ?? "",
            expiryDate: (userInfo["expiryDate"] as? TimeInterval).map { Date(timeIntervalSince1970: $0) }
        )

        if let hostingController {
            hostingController.rootView = card
            return
        }

        let hosting = UIHostingController(rootView: card)
        addChild(hosting)
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hosting.view)
        NSLayoutConstraint.activate([
            hosting.view.topAnchor.constraint(equalTo: view.topAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hosting.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        hosting.didMove(toParent: self)
        hostingController = hosting
    }
}

struct ExpiringIngredientCard: View {
    let ingredientName: String
    let quantityText: String
    let expiryDate: Date?

    private var daysLeftText: String {
        guard let expiryDate else { return "Use it up soon" }
        let calendar = Calendar.current
        let days = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: Date()),
            to: calendar.startOfDay(for: expiryDate)
        ).day ?? 0
        switch days {
        case ..<1: return "Expires today"
        case 1: return "Expires tomorrow"
        default: return "Expires in \(days) days"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Use it up", systemImage: "leaf.fill")
                .font(.caption)
                .foregroundStyle(.green)
            Text(ingredientName)
                .font(.title2.bold())
            if !quantityText.isEmpty {
                Text("You have \(quantityText) in your pantry")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Text(daysLeftText)
                .font(.headline)
                .foregroundStyle(.orange)
            if let expiryDate {
                Text("Use by \(expiryDate.formatted(date: .long, time: .omitted))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding()
    }
}
