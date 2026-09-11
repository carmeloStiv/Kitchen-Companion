//
//  TravelJourney.swift
//  Travel Companion
//
//  Created by Carmelo Stivala on 11/9/2026.
//

import Foundation

enum JourneyStatus: Equatable {
    case notStarted //no journey exists yet
    case inProgress //traveller is currently travelling
    case arrived //traveller has reached the destination
}

struct TravelJourney: Equatable{
    let destination: Destination
    let route: TransportRoute
    var currentStopIndex: Int //which stop in route.stops the traveller is at right now
    var status: JourneyStatus
    
    var stopsRemaining: Int {
        route.stops.count - 1 - currentStopIndex
    }
}
