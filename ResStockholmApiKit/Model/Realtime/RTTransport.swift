//
//  RTTransport.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-01-19.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation

open class RTTransport {

  open let stopAreaName: String
  open let lineNumber: String
  open let destination: String
  open let displayTime: String
  open let deviations: [String]
  open let journeyDirection: Int
  open let stopPointDesignation: String?
  open let groupOfLine: String?
  open let secondaryDestinationName: String?

  
  /**
   * Init
   */
  init(stopAreaName: String, lineNumber: String, destination: String,
    displayTime: String, deviations: [String], journeyDirection: Int,
    stopPointDesignation: String?, groupOfLine: String?,
    secondaryDestinationName: String?) {
  
    self.stopAreaName = stopAreaName
    self.lineNumber = lineNumber
    self.destination = destination
    self.displayTime = displayTime
    self.deviations = deviations
    self.journeyDirection = journeyDirection
    self.stopPointDesignation = stopPointDesignation
    self.groupOfLine = groupOfLine
    self.secondaryDestinationName = secondaryDestinationName
  }
}
