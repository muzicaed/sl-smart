//
//  Station.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-20.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation

class Station: NSObject, NSCoding {
  
  let siteId: Int
  let name: String
  let area: String
  var xCoord: Int
  var yCoord: Int
  
  /**
   * Standard init
   */
  init(id: Int, name: String, area: String, xCoord: Int, yCoord: Int) {
    self.siteId = id
    self.name = name
    self.area = area
    self.xCoord = xCoord
    self.yCoord = yCoord
  }
  
  // MARK: NSCoding
  
  /**
  * Decoder init
  */
  required convenience init?(coder aDecoder: NSCoder) {
    let siteId = aDecoder.decodeIntegerForKey(PropertyKey.siteId)
    let name = aDecoder.decodeObjectForKey(PropertyKey.name) as! String
    let area = aDecoder.decodeObjectForKey(PropertyKey.area) as! String
    let xCoord = aDecoder.decodeIntegerForKey(PropertyKey.xCoord)
    let yCoord = aDecoder.decodeIntegerForKey(PropertyKey.yCoord)
    
    self.init(id: siteId, name: name, area: area, xCoord: xCoord, yCoord: yCoord)
  }
  
  /**
   * Encode this object
   */
  func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeInteger(siteId, forKey: PropertyKey.siteId)
    aCoder.encodeObject(name, forKey: PropertyKey.name)
    aCoder.encodeObject(area, forKey: PropertyKey.area)
    aCoder.encodeInteger(xCoord, forKey: PropertyKey.xCoord)
    aCoder.encodeInteger(yCoord, forKey: PropertyKey.yCoord)
  }
  
  struct PropertyKey {
    static let siteId = "siteId"
    static let name = "name"
    static let area = "area"
    static let xCoord = "xCoord"
    static let yCoord = "yCoord"
  }
}