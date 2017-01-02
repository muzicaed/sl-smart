//
//  RTTram.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-01-24.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation

open class RTTram: RTTransportBase {
  
  open let stopPointDesignation: String?
  open let groupOfLine: String
  
  /**
   * Init
   */
  init(stopAreaName: String, lineNumber: String, destination: String,
    displayTime: String, deviations: [String], journeyDirection: Int,
    stopPointDesignation: String?, groupOfLine: String) {
      
      self.stopPointDesignation = stopPointDesignation
      self.groupOfLine = groupOfLine
      
      super.init(stopAreaName: stopAreaName, lineNumber: lineNumber,
        destination: destination.capitalized, displayTime: displayTime,
        deviations: deviations, journeyDirection: journeyDirection)
  }
}
