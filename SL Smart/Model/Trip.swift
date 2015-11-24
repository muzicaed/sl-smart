//
//  Trip.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-20.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation

class Trip {
  
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
  
  init() {}
}
