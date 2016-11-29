//
//  RTBus.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-01-19.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation

open class RTBus: RTTransportBase {
  
  open let stopPointDesignation: String?
  
  /**
   * Init
   */
  init(stopAreaName: String, lineNumber: String, destination: String,
    displayTime: String, deviations: [String], journeyDirection: Int,
    stopPointDesignation: String?) {
      
      self.stopPointDesignation = stopPointDesignation
      
      super.init(stopAreaName: stopAreaName, lineNumber: lineNumber, destination: destination,
        displayTime: displayTime, deviations: deviations, journeyDirection: journeyDirection)
  }
}
