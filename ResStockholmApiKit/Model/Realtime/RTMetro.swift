//
//  RTMetro.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-01-19.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//
import Foundation

open class RTMetro: RTTransportBase {
  
  open let platformMessage: String?
  open let metroLineId: Int
  
  /**
   * Init
   */
  init(stopAreaName: String, lineNumber: String, destination: String,
    displayTime: String, deviations: [String], journeyDirection: Int,
    platformMessage: String?, metroLineId: Int) {
      
      self.platformMessage = platformMessage
      self.metroLineId = metroLineId
      
      super.init(stopAreaName: stopAreaName, lineNumber: lineNumber,
        destination: destination, displayTime: displayTime,
        deviations: deviations, journeyDirection: journeyDirection)
  }
}
