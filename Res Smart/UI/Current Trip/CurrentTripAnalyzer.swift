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
   * Finds active segment
   */
  func findActiveSegments() -> CurrentTripResult {
    for (index, segment) in currentTrip!.allTripSegments.enumerated() {
      if let result = handleSegment(index, segment) {
        return result
      }
    }
    print("Should not go here!")
    return CurrentTripResult(currentTrip!.allTripSegments.count - 1, currentTrip!.allTripSegments.last!, .Arrived)
  }
  
  /**
   * Finds next segment
   */
  func findNextStep(_ idx: Int) -> CurrentTripResult? {
    if idx + 1 < currentTrip!.allTripSegments.count {
      let active = findActiveSegments()
      let segment = currentTrip!.allTripSegments[idx + 1]
      if active.instruction == .Waiting {
        return (validNextSegment(active.segment)) ? CurrentTripResult(idx, active.segment, .Riding) : nil
      } else if segment.type == .Walk {
        return (validNextSegment(segment)) ? CurrentTripResult(idx, segment, .Walking) : nil
      }
      return CurrentTripResult(idx, segment, .Waiting)
    }
    return nil
  }
  
  /**
   * Checks if segment should display as next segment.
   */
  func validNextSegment(_ segment: TripSegment) -> Bool {
    let now = Date()
    return (now > segment.departureDateTime.addingTimeInterval(-2.0 * 60.0))
  }
  
  // MARK: Private
  
  /**
   * Handle segment
   */
  fileprivate func handleSegment(_ idx: Int, _ segment: TripSegment) -> CurrentTripResult? {
    if isLast(idx) {
      return handleActiveSegment(idx, segment)
      
    } else if isWaitingForFirst(idx, segment) {
      return handleBetweenSegment(idx)
      
    } else if isActive(segment) {
      return handleActiveSegment(idx, segment)
      
    } else if isBetween(idx, segment) {
      return handleBetweenSegment(idx + 1)
    }
    return nil
  }
  
  /**
   * Handle actie segment
   */
  fileprivate func handleActiveSegment(_ idx: Int, _ segment: TripSegment) -> CurrentTripResult {
    if segment.type == .Walk {
      return CurrentTripResult(idx, segment, .Walking)
    }
    return CurrentTripResult(idx, segment, .Riding)
  }
  
  /**
   * Handle between segment
   */
  fileprivate func handleBetweenSegment(_ idx: Int) -> CurrentTripResult {
    let segment = currentTrip!.allTripSegments[idx]
    if segment.type == .Walk {
      return CurrentTripResult(idx, segment, .Walking)
    }
    return CurrentTripResult(idx, segment, .Waiting)
  }
  
  /**
   * Check if waiting for first active
   */
  fileprivate func isWaitingForFirst(_ idx: Int, _ segment: TripSegment) -> Bool {
    let now = Date()
    return (idx == 0 && now < segment.departureDateTime.addingTimeInterval(0.5 * 60.0))
  }
  
  /**
   * Check if active segment
   */
  fileprivate func isActive(_ segment: TripSegment) -> Bool {
    let now = Date()
    return (now > segment.departureDateTime && now < segment.arrivalDateTime.addingTimeInterval(1.2 * 60.0))
  }
  
  /**
   * Check if between segments
   */
  fileprivate func isBetween(_ idx: Int, _ segment: TripSegment) -> Bool {
    let now = Date()
    let nextSegment = currentTrip!.allTripSegments[idx + 1]
    return (now > segment.arrivalDateTime && now < nextSegment.departureDateTime.addingTimeInterval(0.5 * 60.0))
  }
  
  /**
   * Check if last segment
   */
  fileprivate func isLast(_ idx: Int) -> Bool {
    return (idx == currentTrip!.allTripSegments.count - 1)
  }
}


public enum InstructionType: String {
  case Riding = "RIDING"
  case Walking = "WALKING"
  case Waiting = "WAITING"
  case Arrived = "ARRIVIED"
}
