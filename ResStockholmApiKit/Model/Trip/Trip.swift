//
//  Trip.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-20.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation

open class Trip: NSObject, NSCopying {
  
  open var durationMin = 0
  open var noOfChanges = 0
  open var isValid = true
  open var tripSegments = [TripSegment]()
  open var allTripSegments = [TripSegment]()
  
  /**
   * Standard init
   */
  public init(durationMin: Int, noOfChanges: Int, isValid: Bool, tripSegments: [TripSegment]?) {
    self.durationMin = durationMin
    self.noOfChanges = noOfChanges
    self.isValid = isValid
    if let segments = tripSegments {
      self.allTripSegments = segments
      for segment in segments {
        if !(segment.type == .Walk && segment.distance! < 250) {
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
      "dur": durationMin as AnyObject,
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
  
  // MARK: NSCopying
  
  /**
   * Copy self
   */
  open func copy(with zone: NSZone?) -> Any {
    var tripSegmentCopy = [TripSegment]()
    for segment in tripSegments {
      tripSegmentCopy.append(segment.copy() as! TripSegment)
    }
    return Trip(durationMin: durationMin, noOfChanges: noOfChanges, isValid: isValid, tripSegments: tripSegmentCopy)
  }
}
