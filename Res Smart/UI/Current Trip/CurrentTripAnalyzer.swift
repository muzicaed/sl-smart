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
      if let result = handleSegment(index, segment) {
        return result
      }
    }
    print("Should not go here!")
    return CurrentTripResult(currentTrip!.allTripSegments.count - 1, currentTrip!.allTripSegments.last!, .Arrived)
  }
  
  /**
   * Returns route coordinates for the current trip segment.
   */
  func findNextStep(_ currentIndex: Int) -> CurrentTripResult {
    let segment = currentTrip!.allTripSegments[currentIndex]
    //let nextSegment = currentTrip!.allTripSegments[currentIndex + 1]
    return CurrentTripResult(currentIndex + 1, segment, .Walking)
  }
  
  // MARK: Private
  
  /**
   * Handle segment
   */
  fileprivate func handleSegment(_ idx: Int, _ segment: TripSegment) -> CurrentTripResult? {
    if isLast(idx, count: currentTrip!.allTripSegments.count) {
      return handleActiveSegment(idx, segment)
    }
    
    let nextSegment = currentTrip!.allTripSegments[idx + 1]
    if isWaitingForFirst(idx, segment) {
      return handleBetweenSegment(idx, segment)
    } else if isActive(segment) {
      return handleActiveSegment(idx, segment)
    } else if isBetween(segment, nextSegment) {
      return handleBetweenSegment(idx + 1, nextSegment)
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
  fileprivate func handleBetweenSegment(_ idx: Int, _ segment: TripSegment) -> CurrentTripResult {
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
    return (idx == 0 && now < segment.departureDateTime)
  }
  
  /**
   * Check if active segment
   */
  fileprivate func isActive(_ segment: TripSegment) -> Bool {
    let now = Date()
    return (now > segment.departureDateTime && now < segment.arrivalDateTime)
  }
  
  /**
   * Check if between segments
   */
  fileprivate func isBetween(_ segment: TripSegment, _ nextSegment: TripSegment) -> Bool {
    let now = Date()
    return (now > segment.arrivalDateTime && now < nextSegment.departureDateTime)
  }
  
  /**
   * Check if last segment
   */
  fileprivate func isLast(_ idx: Int, count: Int) -> Bool {
    return (idx == count - 1)
  }
}


public enum InstructionType: String {
  case Riding = "RIDING"
  case Walking = "WALKING"
  case Waiting = "WAITING"
  case Arrived = "ARRIVIED"
}
