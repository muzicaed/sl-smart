//
//  StopEnhancer.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-09-07.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation
import CoreLocation

public class StopEnhancer {
  
  /**
   * Enhance stop data for a trip.
   */
  public static func enhance(trip: Trip) {
    for (index, segment) in trip.allTripSegments.enumerate() {
      if segment.type == .Metro {
        var nextSegment: TripSegment? = nil
        if index + 1 < trip.allTripSegments.count {
          nextSegment = trip.allTripSegments[index + 1]
        }
        enhanceSegment(segment, next: nextSegment)
      }
    }
  }
  
  /**
   * Enhance stop data for a segment.
   */
  static private func enhanceSegment(segment: TripSegment, next: TripSegment?) {
    if let nextSegment = next {
      if nextSegment.type == .Walk {
        enhanceWalk(segment, nextSegment: nextSegment)
      } else if nextSegment.type == .Bus {
        enhanceBus(segment, nextSegment: nextSegment)
      } else {
        
      }
    }
  }
  
  /**
   * Enhance stop data for walk segment.
   */
  static private func enhanceWalk(segment: TripSegment, nextSegment: TripSegment) {
    let stop = StopsStore.sharedInstance.getOnId(segment.destination.siteId!)
    if stop.exits.count > 0  {
      let exit = findClosestExit(nextSegment.destination.location, exits: stop.exits)
      segment.exitText = exit.name
      segment.trainPositionText = createTrainPositionText(segment, exit: exit)
    }
  }
  
  /**
   * Enhance stop data for bus segment.
   */
  static private func enhanceBus(segment: TripSegment, nextSegment: TripSegment) {
    let stop = StopsStore.sharedInstance.getOnId(segment.destination.siteId!)
    if stop.exits.count > 0  {
      let exit = findClosestExit(nextSegment.stops.first!.location, exits: stop.exits)
      segment.exitText = exit.name
    }
  }
  
  /**
   * Find closest exit
   */
  static private func findClosestExit(dest: CLLocation, exits: [StaticExit]) -> StaticExit {
    return exits.minElement { $0.location.distanceFromLocation(dest) < $1.location.distanceFromLocation(dest)}!
  }
  
  /**
   * Create train position text
   */
  static private func createTrainPositionText(segment: TripSegment, exit: StaticExit) -> String? {
    // TODO: More directions here...
    if let trainDirection = segment.directionText {
      var trainPos = StaticExit.TrainPosition.Middle
      
      switch trainDirection {
      case "Hjulsta", "Akalla", "Hässelby strand", "Åkeshov", "Alvik", "Ropsten", "Mörby Centrum":
        trainPos = exit.trainPosition
      default:
        // Invert
        if exit.trainPosition != .Middle {
          trainPos = (exit.trainPosition == .Front) ? .Back : .Middle
        }
      }
      
      switch trainPos {
      case .Front:
        return "Åk långt fram"
      case .Middle:
        return "Åk mitten av tåget"
      case .Back:
        return "Åk långt bak"
      }
    }
    return nil
  }
}