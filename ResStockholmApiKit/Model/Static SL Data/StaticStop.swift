//
//  StaticStop.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-09-06.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation
import CoreLocation

public class StaticStop: NSObject, NSCoding {
  
  public let stopPointNumber: String
  public let stopPointName: String
  public let stopAreaNumber: String
  public let location: CLLocation
  public let type: TripType
  public var exits: [StaticExit]
  
  /**
   * Standard init
   */
  public init(stopPointNumber: String, stopPointName: String, stopAreaNumber: String, location: CLLocation, type: TripType) {
    self.stopPointNumber = stopPointNumber
    self.stopPointName = stopPointName
    self.stopAreaNumber = stopAreaNumber
    self.location = location
    self.type = type
    self.exits = ExitData.getExits(stopAreaNumber)
  }
  
  // MARK: NSCoding
  
  /**
   * Decoder init
   */
  required convenience public init?(coder aDecoder: NSCoder) {
    let stopPointNumber = aDecoder.decodeObjectForKey(PropertyKey.stopPointNumber) as! String
    let stopPointName = aDecoder.decodeObjectForKey(PropertyKey.stopPointName) as! String
    let stopAreaNumber = aDecoder.decodeObjectForKey(PropertyKey.stopAreaNumber) as! String
    let location = aDecoder.decodeObjectForKey(PropertyKey.location) as! CLLocation
    let type = aDecoder.decodeObjectForKey(PropertyKey.type) as! String
    let exits = aDecoder.decodeObjectForKey(PropertyKey.exits)  as! [StaticExit]
    
    self.init(stopPointNumber: stopPointNumber, stopPointName: stopPointName,
              stopAreaNumber: stopAreaNumber, location: location, type: TripType(rawValue: type)!)
    self.exits = exits
  }
  
  /**
   * Encode this object
   */
  public func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(stopPointNumber, forKey: PropertyKey.stopPointNumber)
    aCoder.encodeObject(stopPointName, forKey: PropertyKey.stopPointName)
    aCoder.encodeObject(stopAreaNumber, forKey: PropertyKey.stopAreaNumber)
    aCoder.encodeObject(location, forKey: PropertyKey.location)
    aCoder.encodeObject(type.rawValue, forKey: PropertyKey.type)
    aCoder.encodeObject(exits, forKey: PropertyKey.exits)
  }
  
  struct PropertyKey {
    static let stopPointNumber = "stopPointNumber"
    static let stopPointName = "stopPointName"
    static let stopAreaNumber = "stopAreaNumber"
    static let location = "location"
    static let type = "type"
    static let exits = "exits"
  }
}