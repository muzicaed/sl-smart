//
//  RTBoat.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-01-24.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation

public class RTBoat: RTTransportBase {
  
  public let groupOfLine: String
  
  /**
   * Init
   */
  init(stopAreaName: String, lineNumber: String, destination: String,
    displayTime: String, deviations: [String], journeyDirection: Int,
    groupOfLine: String) {
      
      self.groupOfLine = groupOfLine
      
      super.init(stopAreaName: stopAreaName, lineNumber: lineNumber, destination: destination,
        displayTime: displayTime, deviations: deviations, journeyDirection: journeyDirection)
  }
}