//
//  StartTravelJourneyUseCase.swift
//  Travel Companion
//
//  Created by Carmelo Stivala on 11/9/2026.
//

import Foundation

struct StartTravelJourney{
    enum Failure: LocalizedError, Equatable {
        case destinationMissing
        case routeUnavailable
        
        var errorDescription: String? {
            switch self {
            case .destinationMissing:
                return "We couldn't find this journey. Choose a destination before starting travel mode."
            case .routeUnavailable:
                return "Your route information is unavailable. Choose another route befoe starting travel mode."
            }
        }
    }
    
    func execute(destination: Destination?, route: TransportRoute?) -> Result<TravelJourney, Failure> {
        //Rule 1: must have a destination
        guard let destination else{
            return .failure(.destinationMissing)
        }
        //Rule 2: must have a real route with at least 2 stops (an origin and a destination).
        guard let route, route.stops.count >= 2 else{
            return .failure(.routeUnavailable)
        }
        //if everything is right, creates the journey starting at the first stop
        let journey = TravelJourney(
            destination: destination,
            route: route,
            currentStopIndex: 0,
            status: .inProgress
        )
        return .success(journey)
    }
}
