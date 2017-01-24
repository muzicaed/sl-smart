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
  
  var currentTrip: Trip?
  
  /**
   * Returns route coordinates for the current trip segment.
   */
  func findActiveSegments() -> CurrentTripResult {

    for (index, segment) in currentTrip!.allTripSegments.enumerated() {
      if (index + 1) == currentTrip!.allTripSegments.count {
        if segment.type == .Walk {
          return CurrentTripResult(segment, nil, .WalkingLast)
        }
        return CurrentTripResult(segment, nil, .Riding)
      }
      
      if let returnTuple = handleSegment(index, segment) {
        return returnTuple
      }
    }
    print("Should not go here!")
    return CurrentTripResult(currentTrip!.allTripSegments.last!, nil, .Arrived)
  }
  
  // MARK: Private
  
  /**
   * Handles segment
   */
  fileprivate func handleSegment(_ index: Int, _ segment: TripSegment) -> CurrentTripResult? {
    let now = Date()
    let nextSegment = currentTrip!.allTripSegments[index + 1]
    if index == 0 && now < segment.departureDateTime {
      // First segment
      if segment.type == .Walk {
        return CurrentTripResult(segment, nextSegment, .Walking)
      }
      return CurrentTripResult(segment, nil, .Waiting)
    } else if now > segment.departureDateTime && now < segment.arrivalDateTime {
      // Riding/Walking a segment
      return (segment.type == .Walk) ? CurrentTripResult(segment, nextSegment, .Walking) : CurrentTripResult(segment, nil, .Riding)
    } else if now > segment.arrivalDateTime && now < nextSegment.departureDateTime {
      // In between two segments (Waiting)
      if nextSegment.type == .Walk {
        if (index + 2) < currentTrip!.allTripSegments.count {
          // TODO: Not good... need to find next non walk segment...
          let nextNextSegment = currentTrip!.allTripSegments[index + 2]
          return CurrentTripResult(nextSegment, nextNextSegment, .Walking)
        }
        return CurrentTripResult(nextSegment, nextSegment, .Walking)
      }
      return CurrentTripResult(nextSegment, nil, .Waiting)
    }
    return nil
  }
}


public enum InstructionType: String {
  case Riding = "RIDING"
  case Walking = "WALKING"
  case WalkingLast = "WALKING_LAST"
  case Waiting = "WAITING"
  case Arrived = "ARRIVIED"
}
