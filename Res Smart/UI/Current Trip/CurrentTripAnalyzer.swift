//
//  CurrentTripAnalyzer.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2017-01-24.
//  Copyright © 2017 Mikael Hellman. All rights reserved.
//

import Foundation
import ResStockholmApiKit
import MapKit

class CurrentTripAnalyzer {
  
  
  /**
   * Returns route coordinates for the current trip segment.
   */
  static func findActiveSegments(_ trip: Trip) -> (TripSegment, InstructionType) {
    let now = Date()
    for (index, segment) in trip.allTripSegments.enumerated() {
      
      // Waiting for first segment
      if now < segment.departureDateTime {
        return (segment, .Waiting)
      }
      
      // Riding/Walking a segment
      if now > segment.departureDateTime && now < segment.arrivalDateTime {
        return (segment.type == .Walk) ? (segment, .Walking) : (segment, .Riding)
      }
      
      // In between two segments (Waiting)
      if (index + 1) < trip.allTripSegments.count {
        let nextSegment = trip.allTripSegments[index + 1]
        if now > segment.arrivalDateTime && now < nextSegment.departureDateTime {
          return (nextSegment.type == .Walk) ? (segment, .Waiting) : (nextSegment, .Waiting)
        }
      }
    }
    
    // This trip have passed
    return (trip.allTripSegments.last!, .Passed)
  }
  
  // MARK: Private
  
}


public enum InstructionType: String {
  case Riding = "RIDING"
  case Walking = "WALKING"
  case Waiting = "WAITING"
  case Passed = "PASSED"
}
