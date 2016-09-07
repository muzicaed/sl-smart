//
//  Stop.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-01-15.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation
import CoreLocation

public class Stop {
  public let id: String
  public let stopPointNumber: String
  public let name: String
  public var depDate: NSDate?
  public var location: CLLocation
  public let type: TripType
  public let exits: [StaticExit]
  
  init(id: String, depDate: String?, depTime: String?) {
    self.id = id
    self.stopPointNumber = Stop.convertId(id)
    let staticStop = StopsStore.sharedInstance.getOnId(self.stopPointNumber)
    self.name = staticStop.stopPointName
    self.location = staticStop.location
    self.type = staticStop.type
    self.exits = staticStop.exits
    
    if let date = depDate, time = depTime {
      self.depDate = DateUtils.convertDateString("\(date) \(time)")
    }
  }
  
  /**
   * Converts id to StopPointNumber
   */
  static func convertId(id: String) -> String {
    let sub = id.substringFromIndex(id.startIndex.advancedBy(4))
    let newId = String(Int(sub)!) // Remove leading zeros
    return newId
  }
}