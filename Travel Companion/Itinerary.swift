//
//  Itinerary.swift
//  Travel Companion
//
//  Created by Carmelo Stivala on 11/9/2026.
//

import Foundation

struct ItineraryActivity: Identifiable, Equatable {
    let id: String //e.g. "Sydney Opera House"
    let title: String //when this activity is planned for
    let scheduledTime: Date
    let destination: Destination? //nil means "no journey needed"
}

struct Itinerary: Equatable{
    let dayLabel: String //e.g. "Sydney Day 1"
    let activities: [ItineraryActivity] //in time order
}
