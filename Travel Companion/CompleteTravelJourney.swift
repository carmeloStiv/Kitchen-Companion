//
//  CompleteTravelJourney.swift
//  Travel Companion
//
//  Created by Carmelo Stivala on 11/9/2026.
//
import Foundation

struct CompleteTravelJourney{
    enum Failure: LocalizedError, Equatable{
        //the journey wasn't in a state where "arrived" was valid yet
        case journeyNotYetStarted
        case destinationNotYetReached
        
        var errorDescription: String? {
            switch self {
            case .journeyNotYetStarted:
                return "This journey hasn't started, so it can't be marked as arrived"
            case .destinationNotYetReached:
                return "You havent reached your destination yet. Keep travelling until the next stop"
            }
        }
    }
    
    func execute(journey: TravelJourney) -> Result<TravelJourney, Failure> {
        guard journey.status != .notStarted else{
            return .failure(.journeyNotYetStarted)
        }
        
        guard journey.stopsRemaining == 0 else{
            return .failure(.destinationNotYetReached)
        }
        //Copy the journey, flip its status, and return the new version
        var arrivedJourney = journey
        arrivedJourney.status = .arrived
        return .success(arrivedJourney)
    }
}
