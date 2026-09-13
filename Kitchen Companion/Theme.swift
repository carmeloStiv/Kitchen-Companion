//
//  Theme.swift
//  Kitchen Companion
//
//  Created by Carmelo Stivala on 11/9/2026.
//

import SwiftUI

// One shared card look so every screen feels like the same app instead of stock Form/List rows.
struct CardBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(.background.secondary, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardBackground())
    }
}
