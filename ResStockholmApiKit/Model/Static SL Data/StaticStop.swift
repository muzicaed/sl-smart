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
  
  public let stopPointNumber: String
  public let stopPointName: String
  public let stopAreaNumber: String
  public let location: CLLocation
  
  /**
   * Standard init
   */
  public init(stopPointNumber: String, stopPointName: String, stopAreaNumber: String, location: CLLocation) {
    self.stopPointNumber = stopPointNumber
    self.stopPointName = stopPointName
    self.stopAreaNumber = stopAreaNumber
    self.location = location
  }
}