//
//  CreateItineraryUseCase.swift
//  Travel Companion
//
//  Created by Carmelo Stivala on 10/9/2026.
//
import Foundation

struct CreateItinerary{
    enum Failure: LocalizedError, Equatable{
        case noActivitiesProvided
        case activitiesOutOfOrder
        
        var errorDescription: String? {
            switch self {
            case .noActivitiesProvided:
                return "Your itinerary needs at least one planned stop. Add an activity to get started."
            case .activitiesOutOfOrder:
                return "Your activities aren't in time order. Check the times and try again."
            }
        }
    }
    
    func execute(dayLabel: String, activities: [ItineraryActivity]) -> Result<Itinerary, Failure> {
        guard !activities.isEmpty else {
            return .failure(Failure.noActivitiesProvided)
        }
        
        let sortedTimes = activities.map { $0.scheduledTime }
        guard sortedTimes == sortedTimes.sorted() else {
            return .failure(Failure.activitiesOutOfOrder)
        }
        
        return .success(Itinerary(dayLabel: dayLabel, activities: activities))
    }
}

