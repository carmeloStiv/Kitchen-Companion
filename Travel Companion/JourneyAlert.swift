//
//  JourneyAlert.swift
//  Travel Companion
//
//  Created by Carmelo Stivala on 11/9/2026.
//

import Foundation

enum JourneyAlert: Equatable{
    case approachingDestination(stopsRemaining: Int) //e.g. "2 stops away"
    case arrived(destinationName: String) //journey is complete
}
