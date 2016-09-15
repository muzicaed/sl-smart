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
        let nextSegment = findNextSegment(index, trip: trip)
        let stop = StopsStore.sharedInstance.getOnId(segment.destination.siteId!)
        enhanceSegment(segment, next: nextSegment, stop: stop)
      }
    }
  }
  
  // MARK: Private
  
  /**
   * Enhance stop data for a segment.
   */
  static private func findNextSegment(index: Int, trip: Trip) -> TripSegment? {
    var nextSegment: TripSegment? = nil
    if index + 1 < trip.allTripSegments.count {
      nextSegment = trip.allTripSegments[index + 1]
      if nextSegment!.type == .Walk && nextSegment!.distance! < 250 {
        if index + 2 < trip.allTripSegments.count {
          print("Skipped one")
          nextSegment = trip.allTripSegments[index + 2]
        }
      }
    }
    
    return nextSegment
  }
  
  
  /**
   * Enhance stop data for a segment.
   */
  static private func enhanceSegment(segment: TripSegment, next: TripSegment?, stop: StaticStop) {
    if let nextSegment = next {
      var exit: StaticExit? = nil
      if stop.exits.count > 0 {
        if nextSegment.type == .Walk {
          exit = enhanceWalk(segment, nextSegment: nextSegment, stop: stop)
        } else if nextSegment.type == .Bus {
          exit = enhanceBus(segment, nextSegment: nextSegment, stop: stop)
        } else {
          exit = enhanceChange(segment, nextSegment: nextSegment, stop: stop)
        }
        prepareExitText(exit, segment: segment)
      }
    }
  }
  
  /**
   * Enhance stop data for walk segment.
   */
  static private func enhanceWalk(segment: TripSegment, nextSegment: TripSegment,
                                  stop: StaticStop) -> StaticExit {
    return findClosestExit(nextSegment.destination.location, exits: stop.exits)
  }
  
  /**
   * Enhance stop data for bus segment.
   */
  static private func enhanceBus(segment: TripSegment, nextSegment: TripSegment,
                                 stop: StaticStop) -> StaticExit {
    return findClosestExit(nextSegment.origin.location, exits: stop.exits)
  }
  
  /**
   * Enhance stop data for change.
   */
  static private func enhanceChange(segment: TripSegment, nextSegment: TripSegment,
                                    stop: StaticStop) -> StaticExit? {
    let line = TripHelper.friendlyLineData(nextSegment).short
    for exit in stop.exits {
      if exit.changeToLines.contains(line) {
        return exit
      }
    }
    return nil
  }
  
  /**
   * Find closest exit
   */
  static private func findClosestExit(dest: CLLocation, exits: [StaticExit]) -> StaticExit {
    return exits.minElement { $0.location.distanceFromLocation(dest) < $1.location.distanceFromLocation(dest)}!
  }
  
  /**
   * Set the exit and train direction text to segemnt
   */
  static private func prepareExitText(exit: StaticExit?, segment: TripSegment) {
    if let exit = exit {
      segment.exitText = exit.name
      segment.trainPositionText = createTrainPositionText(segment, exit: exit)
    }
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
          trainPos = (exit.trainPosition == .Front) ? .Back : .Front
        }
      }
      
      switch trainPos {
      case .Front:
        return "långt fram i tåget"
      case .Middle:
        return "mitten av tåget"
      case .Back:
        return "långt bak i tåget"
      }
    }
    return nil
  }
}