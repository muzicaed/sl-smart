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
  public var tripSegments = [TripSegment]()
  
  /**
   * Standard init
   */
  public init(durationMin: Int, noOfChanges: Int, tripSegments: [TripSegment]?) {
    self.durationMin = durationMin
    self.noOfChanges = noOfChanges
    if let segments = tripSegments {
      self.tripSegments = segments
    }
  }
  
  /**
   * Converts into data dictionary for transfer to AppleWatch.
   */
  public func watchTransferData() -> Dictionary<String, AnyObject> {
    var icons = [String]()
    var lines = [String]()
    for segment in tripSegments {
      let data = TripHelper.friendlyLineData(segment)
      icons.append(data.icon)
      lines.append(data.short)
    }
    
    return [
      "dur": durationMin,
      "icn": icons,
      "lns": lines,
      "origin": tripSegments.first!.origin.name,
      "destination": tripSegments.last!.destination.name,
      "originTime": DateUtils.dateAsDateAndTimeString(tripSegments.first!.departureDateTime),
      "destinationTime": DateUtils.dateAsDateAndTimeString(tripSegments.last!.arrivalDateTime),
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
    return Trip(durationMin: durationMin, noOfChanges: noOfChanges, tripSegments: tripSegmentCopy)
  }
}
