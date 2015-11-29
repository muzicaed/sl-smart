//
//  ScorePost.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-29.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation

class ScorePost: NSObject, NSCoding {

  var dayOfWeek = 0
  var hourOfDay = 0
  var originId = 0
  var destinationId = 0
  
  /**
   * Standard init
   */
  init(dayOfWeek: Int, hourOfDay: Int, originId: Int, destinationId: Int) {
    self.dayOfWeek = dayOfWeek
    self.hourOfDay = hourOfDay
    self.originId = originId
    self.destinationId = destinationId
  }
  
  // MARK: NSCoding  
  
  /**
   * Decoder init
   */
  required convenience init?(coder aDecoder: NSCoder) {
    let dayOfWeek = aDecoder.decodeIntegerForKey(PropertyKey.dayOfWeek)
    let hourOfDay = aDecoder.decodeIntegerForKey(PropertyKey.hourOfDay)
    let originId = aDecoder.decodeIntegerForKey(PropertyKey.originId)
    let destinationId = aDecoder.decodeIntegerForKey(PropertyKey.destinationId)
    
    self.init(
      dayOfWeek: dayOfWeek, hourOfDay: hourOfDay,
      originId: originId, destinationId: destinationId)
  }
  
  /**
   * Encode this object
   */
  func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeInteger(dayOfWeek, forKey: PropertyKey.dayOfWeek)
    aCoder.encodeInteger(hourOfDay, forKey: PropertyKey.hourOfDay)
    aCoder.encodeInteger(originId, forKey: PropertyKey.originId)
    aCoder.encodeInteger(destinationId, forKey: PropertyKey.destinationId)
  }
    
  struct PropertyKey {
    static let dayOfWeek = "dayOfWeek"
    static let hourOfDay = "hourOfDay"
    static let originId = "originId"
    static let destinationId = "destinationId"
  }
}