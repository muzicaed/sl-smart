//
//  ScorePost.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-29.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import CoreLocation

class ScorePost: NSObject, NSCoding, NSCopying {
  
  var dayInWeek = 0
  var hourOfDay = 0
  var siteId = 0
  var score = Float(0.0)
  var isOrigin = false
  var location: CLLocation?
  
  /**
   * Standard init
   */
  init(dayInWeek: Int, hourOfDay: Int, siteId: Int,
    score: Float, isOrigin: Bool, location: CLLocation?) {
      self.dayInWeek = dayInWeek
      self.hourOfDay = hourOfDay
      self.siteId = siteId
      self.score = score
      self.isOrigin = isOrigin
      self.location = location
  }
  
  // MARK: NSCoding
  
  /**
  * Decoder init
  */
  required convenience init?(coder aDecoder: NSCoder) {
    let dayInWeek = aDecoder.decodeIntegerForKey(PropertyKey.dayInWeek)
    let hourOfDay = aDecoder.decodeIntegerForKey(PropertyKey.hourOfDay)
    let siteId = aDecoder.decodeIntegerForKey(PropertyKey.siteId)
    let score = aDecoder.decodeFloatForKey(PropertyKey.score)
    let isOrigin = aDecoder.decodeBoolForKey(PropertyKey.isOrigin)
    let location = aDecoder.decodeObjectForKey(PropertyKey.location) as! CLLocation?
    
    self.init(
      dayInWeek: dayInWeek, hourOfDay: hourOfDay,
      siteId: siteId, score: score,
      isOrigin: isOrigin, location: location)
  }
  
  /**
   * Encode this object
   */
  func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeInteger(dayInWeek, forKey: PropertyKey.dayInWeek)
    aCoder.encodeInteger(hourOfDay, forKey: PropertyKey.hourOfDay)
    aCoder.encodeInteger(siteId, forKey: PropertyKey.siteId)
    aCoder.encodeFloat(score, forKey: PropertyKey.score)
    aCoder.encodeBool(isOrigin, forKey: PropertyKey.isOrigin)
    aCoder.encodeObject(location, forKey: PropertyKey.location)
  }
  
  struct PropertyKey {
    static let dayInWeek = "dayInWeek"
    static let hourOfDay = "hourOfDay"
    static let siteId = "siteId"
    static let score = "score"
    static let isOrigin = "isOrigin"
    static let location = "location"
  }
  
  // MARK: NSCopying
  
  /**
  * Copy self
  */
  func copyWithZone(zone: NSZone) -> AnyObject {
    var locationCopy: CLLocation? = nil
    if let location = location {
      locationCopy = location.copy() as? CLLocation
    }
    
    return ScorePost(
      dayInWeek: dayInWeek, hourOfDay: hourOfDay,
      siteId: siteId, score: score, isOrigin: isOrigin, location: locationCopy)
  }
}