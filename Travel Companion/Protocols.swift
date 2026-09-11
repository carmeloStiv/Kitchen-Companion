//
//  Protocols.swift
//  Travel Companion
//
//  Created by Carmelo Stivala on 11/9/2026.
//

import Foundation

protocol TransportRouteProviding{
    //Returns nil if no route is known for this destination.
    func route(for destination: Destination) -> TransportRoute?
}

protocol ItineraryProviding{
    func currentItinerary() -> Itinerary
}
