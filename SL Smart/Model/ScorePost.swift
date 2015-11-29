//
//  ScorePost.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-29.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation

class ScorePost: NSObject, NSCoding, NSCopying {

  var dayInWeek = 0
  var hourOfDay = 0
  var siteId = 0
  var score = 0
  var isOrigin = false
  
  /**
   * Standard init
   */
  init(dayInWeek: Int, hourOfDay: Int, siteId: Int, score: Int, isOrigin: Bool) {
    self.dayInWeek = dayInWeek
    self.hourOfDay = hourOfDay
    self.siteId = siteId
    self.score = score
    self.isOrigin = isOrigin
  }
  
  // MARK: NSCoding  
  
  /**
   * Decoder init
   */
  required convenience init?(coder aDecoder: NSCoder) {
    let dayInWeek = aDecoder.decodeIntegerForKey(PropertyKey.dayInWeek)
    let hourOfDay = aDecoder.decodeIntegerForKey(PropertyKey.hourOfDay)
    let siteId = aDecoder.decodeIntegerForKey(PropertyKey.siteId)
    let score = aDecoder.decodeIntegerForKey(PropertyKey.score)
    let isOrigin = aDecoder.decodeBoolForKey(PropertyKey.isOrigin)
    
    self.init(
      dayInWeek: dayInWeek, hourOfDay: hourOfDay,
      siteId: siteId, score: score, isOrigin: isOrigin)
  }
  
  /**
   * Encode this object
   */
  func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeInteger(dayInWeek, forKey: PropertyKey.dayInWeek)
    aCoder.encodeInteger(hourOfDay, forKey: PropertyKey.hourOfDay)
    aCoder.encodeInteger(siteId, forKey: PropertyKey.siteId)
    aCoder.encodeInteger(score, forKey: PropertyKey.score)
    aCoder.encodeBool(isOrigin, forKey: PropertyKey.isOrigin)
  }
    
  struct PropertyKey {
    static let dayInWeek = "dayInWeek"
    static let hourOfDay = "hourOfDay"
    static let siteId = "siteId"
    static let score = "score"
    static let isOrigin = "isOrigin"
  }
  
  // MARK: NSCopying
  
  /**
  * Copy self
  */
  func copyWithZone(zone: NSZone) -> AnyObject {
    return ScorePost(
      dayInWeek: dayInWeek, hourOfDay: hourOfDay,
      siteId: siteId, score: score, isOrigin: isOrigin)
  }
}