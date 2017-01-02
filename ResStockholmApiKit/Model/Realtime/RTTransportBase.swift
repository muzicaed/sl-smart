//
//  RTTransportBase.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-01-19.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation

open class RTTransportBase {

  open let stopAreaName: String
  open let lineNumber: String
  open let destination: String
  open let displayTime: String
  open let deviations: [String]
  open let journeyDirection: Int

  
  /**
   * Init
   */
  init(stopAreaName: String, lineNumber: String, destination: String,
    displayTime: String, deviations: [String], journeyDirection: Int) {
  
      self.stopAreaName = stopAreaName
      self.lineNumber = lineNumber
      self.destination = destination
      self.displayTime = displayTime
      self.deviations = deviations
      self.journeyDirection = journeyDirection
  }
}
