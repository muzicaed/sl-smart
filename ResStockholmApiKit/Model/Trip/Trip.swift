//
//  Trip.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-20.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation

open class Trip: NSObject, NSCopying {
  
  open var durationText = ""
  open var noOfChanges = 0
  open var isValid = true
  open var tripSegments = [TripSegment]()
  open var allTripSegments = [TripSegment]()
  open var tripKey = ""
  open var criterion: TripSearchCriterion
  
  /**
   * Standard init
   */
  public init(durationText: String, noOfChanges: Int,
              isValid: Bool, tripSegments: [TripSegment]?,
              criterion: TripSearchCriterion) {
    
    self.durationText = durationText
    self.noOfChanges = noOfChanges
    self.isValid = isValid
    self.criterion = criterion
    
    if let segments = tripSegments {
      self.tripKey = Trip.generateTripKey(segments: segments)
      var lastSegment: TripSegment? = nil
      for segment in segments {
        if let last = lastSegment {
          if last.type == .Walk && segment.type == .Walk {
            // Merge walk segments
            last.destination = segment.destination
            last.durationInMin = last.durationInMin + segment.durationInMin
            if let lastDist = last.distance, let dist = segment.distance {
              last.distance = lastDist + dist
            }
          } else {
            self.allTripSegments.append(last)
          }
        }
        
        if segment == segments.last {
          self.allTripSegments.append(segment)
        }
        lastSegment = segment.copy() as? TripSegment
      }
      
      for segment in self.allTripSegments {
        if !(segment.type == .Walk && segment.distance! < 200) {
          self.tripSegments.append(segment)
        }
      }
    }
  }
  
  /**
   * Checks if any trip segments is realtime.
   */
  open func hasAnyRealtime() -> Bool {
    for segment in tripSegments {
      if segment.isRealtime {
       return true
      }
    }
    return false
  }
  
  /**
   * Checks if any segments are cancelled or not reachable.
   */
  open func checkInvalidSegments() -> (isCancelled: Bool, isReachable: Bool) {
    var returnTuple = (isCancelled: false, isReachable: true)
    
    if !isValid {
      for segment in tripSegments {
        if segment.isCancelled {
          returnTuple.isCancelled = true
        }
        if !segment.isReachable {
          returnTuple.isReachable = false
        }
      }
    }
    return returnTuple
  }
  
  /**
   * Converts into data dictionary for transfer to AppleWatch.
   */
  open func watchTransferData() -> Dictionary<String, AnyObject> {
    var icons = [String]()
    var lines = [String]()
    var warnings = [String]()
    for segment in tripSegments {
      let data = TripHelper.friendlyLineData(segment)
      icons.append(data.icon)
      lines.append(data.short)
      
      var warning = ""
      if segment.rtuMessages != nil {
        warning = (segment.isWarning) ? "W" : "I"
      }
      warnings.append(warning)
    }
    
    return [
      "dur": durationText as AnyObject,
      "icn": icons as AnyObject,
      "lns": lines as AnyObject,
      "war": warnings as AnyObject,
      "val": isValid as AnyObject,
      "ori": tripSegments.first!.origin.name as AnyObject,
      "des": tripSegments.last!.destination.name as AnyObject,
      "ot": DateUtils.dateAsDateAndTimeString(tripSegments.first!.departureDateTime) as AnyObject,
      "dt": DateUtils.dateAsDateAndTimeString(tripSegments.last!.arrivalDateTime) as AnyObject,
    ]
  }
  
  /**
   * Refresh the trip data
   */
  open func refresh(_ newTrip: Trip) {
    allTripSegments = newTrip.allTripSegments
    tripSegments = newTrip.tripSegments
  }
  
  // MARK: Private
  
  fileprivate static func generateTripKey(segments: [TripSegment]) -> String {
    var key = ""
    for segment in segments {
      key += "\(segment.name)-\(segment.origin.name)-\(segment.departureDateTime)-\(segment.destination.name)-\(segment.arrivalDateTime)"
    }
    return key
  }
  
  // MARK: NSCopying
  
  /**
   * Copy self
   */
  open func copy(with zone: NSZone?) -> Any {
    var tripSegmentCopy = [TripSegment]()
    for segment in tripSegments {
      tripSegmentCopy.append(segment.copy() as! TripSegment)
    }
    return Trip(durationText: durationText, noOfChanges: noOfChanges,
                isValid: isValid, tripSegments: tripSegmentCopy,
                criterion: criterion.copy() as! TripSearchCriterion)
  }
}
