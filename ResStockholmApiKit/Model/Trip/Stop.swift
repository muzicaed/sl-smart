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
  public let name: String
  public var depDate: NSDate?
  public var location: CLLocation
  public let type: TripType
  public let exits: [StaticExit]
  
  init(id: String, depDate: String?, depTime: String?) {
    self.id = id
    let staticStop = StopsStore.sharedInstance.getOnId(self.id)
    self.name = staticStop.stopPointName
    self.location = staticStop.location
    self.type = staticStop.type
    self.exits = staticStop.exits
    
    if let date = depDate, time = depTime {
      self.depDate = DateUtils.convertDateString("\(date) \(time)")
    }
  }  
}