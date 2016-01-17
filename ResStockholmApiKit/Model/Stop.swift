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
  public let routeIdx: String
  public let name: String
  public var depDate: NSDate?
  public var location: CLLocation
  
  init(id: String, routeIdx: String, name: String,
    depDate: String?, depTime: String?, lat: String, lon: String) {
      self.id = id
      self.routeIdx = routeIdx
      self.name = name
      
      if let date = depDate, time = depTime {
        self.depDate = DateUtils.convertDateString("\(date) \(time)")
      }
      
      self.location = CLLocation(latitude: Double(lat)!, longitude: Double(lon)!)
  }
}