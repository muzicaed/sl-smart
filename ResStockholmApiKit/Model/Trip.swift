//
//  Trip.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-20.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation

public class Trip: NSObject, NSCopying {
  
  public var durationMin = 0
  public var noOfChanges = 0
  public var isValid = true
  public var tripSegments = [TripSegment]()
  public var allTripSegments = [TripSegment]()
  
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
  public func hasAnyRealtime() -> Bool {
    for segment in tripSegments {
      if segment.isRealtime {
       return true
      }
    }
    return false
  }
  
  /**
   * Converts into data dictionary for transfer to AppleWatch.
   */
  public func watchTransferData() -> Dictionary<String, AnyObject> {
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
      "dur": durationMin,
      "icn": icons,
      "lns": lines,
      "war": warnings,
      "val": isValid,
      "ori": tripSegments.first!.origin.name,
      "des": tripSegments.last!.destination.name,
      "ot": DateUtils.dateAsDateAndTimeString(tripSegments.first!.departureDateTime),
      "dt": DateUtils.dateAsDateAndTimeString(tripSegments.last!.arrivalDateTime),
    ]
  }
  
  // MARK: NSCopying
  
  /**
   * Copy self
   */
  public func copyWithZone(zone: NSZone) -> AnyObject {
    var tripSegmentCopy = [TripSegment]()
    for segment in tripSegments {
      tripSegmentCopy.append(segment.copy() as! TripSegment)
    }
    return Trip(durationMin: durationMin, noOfChanges: noOfChanges, isValid: isValid, tripSegments: tripSegmentCopy)
  }
}
