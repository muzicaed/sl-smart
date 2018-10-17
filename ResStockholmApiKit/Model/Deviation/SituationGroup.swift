//
//  SituationGroup.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-12-10.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation

public class SituationGroup {
    
    public let statusIcon: String // "EventMajor", "EventMinor", "EventGood"
    public let hasPlannedEvent: Bool
    public let name: String
    public let tripType: TripType
    public let iconName: String
    public var situations = [Situation]()
    public var plannedSituations = [Situation]()
    public var deviations = [Deviation]()
    
    
    /**
     * Init
     */
    public init(
        statusIcon: String, hasPlannedEvent: Bool,
        name: String, tripType: String, situations: [Situation]) {
        self.statusIcon = statusIcon
        self.hasPlannedEvent = hasPlannedEvent
        self.name = name
        
        for situation in situations {
            if situation.planned {
                plannedSituations.append(situation)
            } else {
                self.situations.append(situation)
            }
        }
        
        let typeTyple = SituationGroup.createTripType(tripType)
        self.iconName = typeTyple.icon
        self.tripType = typeTyple.type
    }
    
    /**
     * Counts no of situations excluding planned situations.
     */
    public func countSituationsExclPlanned() -> Int {
        var count = 0
        for situation in situations {
            count = (situation.planned) ? count : count + 1
        }    
        return count
    }
    
    
    /**
     * Converts the API's trip type string icon name
     */
    fileprivate static func createTripType(_ typeString: String) -> (type: TripType, icon: String) {
        switch typeString {
        case "metro":
            return (TripType.Metro, "METRO-NEUTRAL")
        case "train":
            return (TripType.Train, "TRAIN-NEUTRAL")
        case "bus":
            return (TripType.Bus, "BUS-NEUTRAL")
        case "tram":
            return (TripType.Tram, "TRAM-RAIL")
        case "local":
            return (TripType.Local, "TRAM-LOCAL")
        case "fer":
            return (TripType.Ship, "SHIP-NEUTRAL")
        default:
            fatalError("Unknown trip type.")
        }
    }
}
