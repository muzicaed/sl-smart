//
//  StaticStop.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-09-06.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation
import CoreLocation

public class StaticStop {
  
  public let stopPointNumber: Int
  public let stopPointName: String
  public let stopAreaNumber: Int
  public let location: CLLocation
  
  /**
   * Standard init
   */
  public init(stopPointNumber: Int, stopPointName: String, stopAreaNumber: Int, location: CLLocation) {
    self.stopPointNumber = stopPointNumber
    self.stopPointName = stopPointName
    self.stopAreaNumber = stopAreaNumber
    self.location = location
  }
}