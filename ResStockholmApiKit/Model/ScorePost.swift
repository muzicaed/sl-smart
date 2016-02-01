//
//  ScorePost.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-29.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import CoreLocation

public class ScorePost: NSObject, NSCoding, NSCopying {
  
  public var dayInWeek = 0
  public var hourOfDay = 0
  public var originId = "0"
  public var destId = "0"
  public var score = Float(0.0)
  public var location: CLLocation?
  
  /**
   * Standard init
   */
  public init(dayInWeek: Int, hourOfDay: Int, originId: String, destId: String,
    score: Float, location: CLLocation?) {
      self.dayInWeek = dayInWeek
      self.hourOfDay = hourOfDay
      self.originId = originId
      self.destId = destId
      self.score = score
      self.location = location
  }
  
  // MARK: NSCoding
  
  /**
  * Decoder init
  */
  required convenience public init?(coder aDecoder: NSCoder) {
    let dayInWeek = aDecoder.decodeIntegerForKey(PropertyKey.dayInWeek)
    let hourOfDay = aDecoder.decodeIntegerForKey(PropertyKey.hourOfDay)
    let originId = aDecoder.decodeObjectForKey(PropertyKey.originId) as! String
    let destId = aDecoder.decodeObjectForKey(PropertyKey.destId) as! String
    let score = aDecoder.decodeFloatForKey(PropertyKey.score)
    let location = aDecoder.decodeObjectForKey(PropertyKey.location) as! CLLocation?
    
    self.init(
      dayInWeek: dayInWeek, hourOfDay: hourOfDay,
      originId: originId, destId: destId,
      score: score, location: location)
  }
  
  /**
   * Encode this object
   */
  public func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeInteger(dayInWeek, forKey: PropertyKey.dayInWeek)
    aCoder.encodeInteger(hourOfDay, forKey: PropertyKey.hourOfDay)
    aCoder.encodeObject(originId, forKey: PropertyKey.originId)
    aCoder.encodeObject(destId, forKey: PropertyKey.destId)
    aCoder.encodeFloat(score, forKey: PropertyKey.score)
    aCoder.encodeObject(location, forKey: PropertyKey.location)
  }
  
  struct PropertyKey {
    static let dayInWeek = "dayInWeek"
    static let hourOfDay = "hourOfDay"
    static let originId = "originId"
    static let destId = "destId"
    static let score = "score"
    static let location = "location"
  }
  
  // MARK: NSCopying
  
  /**
  * Copy self
  */
  public func copyWithZone(zone: NSZone) -> AnyObject {
    var locationCopy: CLLocation? = nil
    if let location = location {
      locationCopy = location.copy() as? CLLocation
    }
    
    return ScorePost(
      dayInWeek: dayInWeek, hourOfDay: hourOfDay,
      originId: originId, destId: destId, score: score, location: locationCopy)
  }
}