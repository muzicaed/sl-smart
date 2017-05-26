//
//  StopEnhancer.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-09-07.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation
import CoreLocation

open class StopEnhancer {
  
  /**
   * Enhance stop data for a trip.
   */
  open static func enhance(_ trip: Trip) {
    for (index, segment) in trip.allTripSegments.enumerated() {
      if segment.type == .Metro {
        let nextSegment = findNextSegment(index, trip: trip)
        if let stop = StopsStore.sharedInstance.getOnId(segment.destination.siteId!) {
          enhanceSegment(segment, next: nextSegment, stop: stop)
        }
      }
    }
  }
  
  // MARK: Private
  
  /**
   * Enhance stop data for a segment.
   */
  static fileprivate func findNextSegment(_ index: Int, trip: Trip) -> TripSegment? {
    var nextSegment: TripSegment? = nil
    if index + 1 < trip.allTripSegments.count {
      nextSegment = trip.allTripSegments[index + 1]
      if nextSegment!.type == .Walk && nextSegment!.distance! < 250 {
        if index + 2 < trip.allTripSegments.count {
          nextSegment = trip.allTripSegments[index + 2]
        }
      }
    }
    
    return nextSegment
  }
  
  
  /**
   * Enhance stop data for a segment.
   */
  static fileprivate func enhanceSegment(_ segment: TripSegment, next: TripSegment?, stop: StaticStop) {
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
  static fileprivate func enhanceWalk(_ segment: TripSegment, nextSegment: TripSegment,
                                      stop: StaticStop) -> StaticExit? {
    if let location = nextSegment.destination.location {
      return findClosestExit(location, exits: stop.exits)
    }
    return nil
  }
  
  /**
   * Enhance stop data for bus segment.
   */
  static fileprivate func enhanceBus(_ segment: TripSegment, nextSegment: TripSegment,
                                     stop: StaticStop) -> StaticExit? {
    if let location = nextSegment.origin.location {
      return findClosestExit(location, exits: stop.exits)
    }
    return nil
  }
  
  /**
   * Enhance stop data for change.
   */
  static fileprivate func enhanceChange(_ segment: TripSegment, nextSegment: TripSegment,
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
  static fileprivate func findClosestExit(_ dest: CLLocation, exits: [StaticExit]) -> StaticExit {
    return exits.min { $0.location.distance(from: dest) < $1.location.distance(from: dest)}!
  }
  
  /**
   * Set the exit and train direction text to segemnt
   */
  static fileprivate func prepareExitText(_ exit: StaticExit?, segment: TripSegment) {
    if let exit = exit {
      segment.exitText = exit.name
      segment.trainPositionText = createTrainPositionText(segment, exit: exit)
    }
  }
  
  /**
   * Create train position text
   */
  static fileprivate func createTrainPositionText(_ segment: TripSegment, exit: StaticExit) -> String? {
    if let trainDirection = segment.directionText {
      var trainPos = StaticExit.TrainPosition.middle
      
      switch trainDirection {
      case "Hjulsta", "Akalla", "Hässelby strand", "Åkeshov", "Alvik", "Ropsten", "Mörby Centrum":
        trainPos = exit.trainPosition
      default:
        // Invert
        if exit.trainPosition != .middle {
          trainPos = (exit.trainPosition == .front) ? .back : .front
        }
      }
      
      switch trainPos {
      case .front:
        return "start of train".localized
      case .middle:
        return "middle of train".localized
      case .back:
        return "end of train".localized
      }
    }
    return nil
  }
}
