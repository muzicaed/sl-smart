//
//  StaticExit.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-09-07.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation
import CoreLocation

public class StaticExit {
  
  public let name: String
  public let location: CLLocation
  public let trainPosition: TrainPosition
  public let changeToLines: [String]
  
  
  /**
   * Standard init
   */
  public init(name: String, location: CLLocation, trainPosition: Int, changeToLines: [String]) {
    self.name = name
    self.location = location
    self.changeToLines = changeToLines
    self.trainPosition = TrainPosition(rawValue: trainPosition)!
  }
  
  public enum TrainPosition: Int {
    case Front = 0
    case Middle = 1
    case Back = 2
  }
}