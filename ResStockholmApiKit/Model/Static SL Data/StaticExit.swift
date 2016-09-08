//
//  StaticExit.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-09-07.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation
import CoreLocation

public class StaticExit: NSObject, NSCoding {
  
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
  
  // MARK: NSCoding
  
  /**
   * Decoder init
   */
  required convenience public init?(coder aDecoder: NSCoder) {
    let name = aDecoder.decodeObjectForKey(PropertyKey.name) as! String
    let location = aDecoder.decodeObjectForKey(PropertyKey.location) as! CLLocation
    let trainPosition = aDecoder.decodeIntegerForKey(PropertyKey.trainPosition)
    let changeToLines = aDecoder.decodeObjectForKey(PropertyKey.changeToLines)  as! [String]
    
    self.init(name: name, location: location, trainPosition: trainPosition, changeToLines: changeToLines)
  }
  
  /**
   * Encode this object
   */
  public func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(name, forKey: PropertyKey.name)
    aCoder.encodeObject(location, forKey: PropertyKey.location)
    aCoder.encodeInteger(trainPosition.rawValue, forKey: PropertyKey.trainPosition)
    aCoder.encodeObject(changeToLines, forKey: PropertyKey.changeToLines)
  }
  
  struct PropertyKey {
    static let name = "name"
    static let location = "location"
    static let trainPosition = "trainPosition"
    static let changeToLines = "changeToLines"
  }
}