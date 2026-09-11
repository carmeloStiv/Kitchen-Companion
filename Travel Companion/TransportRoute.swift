//
//  TransportRoute.swift
//  Travel Companion
//
//  Created by Carmelo Stivala on 11/9/2026.
//

import Foundation

struct TransportRoute: Identifiable, Equatable {
    let id: String //unique key for this route
    let name: String // e.g. ""City Circle"
    let stops: [TransportStop] // ordered stops, origin first, destination last
}
