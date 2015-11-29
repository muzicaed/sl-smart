//
//  Trip.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-20.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation

class Trip: NSObject, NSCopying {
  
  var durationMin = 0
  var noOfChanges = 0
  var tripSegments = [TripSegment]()
  
  /**
   * Standard init
   */
  init(durationMin: Int, noOfChanges: Int, tripSegments: [TripSegment]?) {
    self.durationMin = durationMin
    self.noOfChanges = noOfChanges
    if let segments = tripSegments {
      self.tripSegments = segments
    }
  }
  
  // MARK: NSCopying
  
  /**
  * Copy self
  */
  func copyWithZone(zone: NSZone) -> AnyObject {
    var tripSegmentCopy = [TripSegment]()
    for segment in tripSegments {
      tripSegmentCopy.append(segment.copy() as! TripSegment)
    }    
    return Trip(durationMin: durationMin, noOfChanges: noOfChanges, tripSegments: tripSegmentCopy)
  }
}
