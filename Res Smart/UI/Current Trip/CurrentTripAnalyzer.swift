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
    for (index, segment) in trip.allTripSegments.enumerated() {
      if index == 0 {
        return handleFirstSegment(trip, segment)
      } else if (index + 1) < trip.allTripSegments.count {
        return handleLastSegment(trip, segment)
      }
      
      let nextSegment = trip.allTripSegments[index + 1]
      if let returnTuple = handleSegment(trip, segment, nextSegment) {
        return returnTuple
      }
    }
    print("Should not go here!")
  }
  
  // MARK: Private
  
  /**
   * Handles first segment
   */
  fileprivate static func handleFirstSegment(_ trip: Trip,
                                             _ segment: TripSegment) -> (TripSegment, InstructionType) {
    let now = Date()
    // Waiting for first segment
    if now < segment.departureDateTime {
      return (segment, .Waiting)
    }
  }
  
  /**
   * Handles last segment
   */
  fileprivate static func handleLastSegment(_ trip: Trip,
                                            _ segment: TripSegment) -> (TripSegment, InstructionType) {
    
  }
  
  /**
   * Handles segment
   */
  fileprivate static func handleSegment(_ trip: Trip,
                                        _ segment: TripSegment,
                                        _ nextSegment: TripSegment) -> (TripSegment, InstructionType)? {
    let now = Date()
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
}


public enum InstructionType: String {
  case Riding = "RIDING"
  case Walking = "WALKING"
  case Waiting = "WAITING"
  case Passed = "PASSED"
}
