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
  public let type: String
  public let situations: [Situation]
  
  
  /**
   * Init
   */
  public init(
    statusIcon: String, hasPlannedEvent: Bool,
    name: String, tripType: String, situations: [Situation]) {
      self.statusIcon = statusIcon
      self.hasPlannedEvent = hasPlannedEvent
      self.name = name
      self.type = SituationGroup.createTripTypeIconName(tripType)
      self.situations = situations
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
  private static func createTripTypeIconName(typeString: String) -> String {
    switch typeString {
    case "metro":
      return "METRO-NEUTRAL"
    case "train":
      return "TRAIN-NEUTRAL"
    case "bus":
      return "BUS-NEUTRAL"
    case "tram":
      return "TRAM-RAIL"
    case "local":
      return "TRAM-LOCAL"
    case "fer":
      return "SHIP-NEUTRAL"
    default:
      return typeString
    }
  }
}
