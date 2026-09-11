//
//  EvaluateJourneyAlert.swift
//  Travel Companion
//
//  Created by Carmelo Stivala on 11/9/2026.
//

import Foundation

struct EvaluateJourneyAlert{
    enum Failure: LocalizedError, Equatable{
        case journeyNotInProgress
        
        var errorDescription: String?{
            "This journey hasn't started yet, so no alerts can be evaluated."
        }
    }
    
    private static let alertThreshold = 2 //"2 stops away" per app's spec
    
    func execute(journey: TravelJourney, lastAlertIssued: JourneyAlert?) -> Result<JourneyAlert?, Failure>{
        //Can't evaluate an alert for a journey that hasn't started
        guard journey.status == .inProgress else{
            return .failure(.journeyNotInProgress)
        }

        //Work out which alert (if any) matches the current stop count
        let candidateAlert: JourneyAlert?
        
        if journey.stopsRemaining == Self.alertThreshold{
            candidateAlert = .approachingDestination(stopsRemaining: journey.stopsRemaining)
        }
        else if journey.stopsRemaining == 0{
            candidateAlert = .arrived(destinationName: journey.destination.name)
        }
        else{
            candidateAlert = nil
        }
        
        //never issues the same alert case twice in a row
        if let candidateAlert, candidateAlert == lastAlertIssued{
            return .success(nil)
        }
        
        return .success(candidateAlert)
    }
}
