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
  let cleanName: String
  let area: String
  var xCoord: Int
  var yCoord: Int
  
  /**
   * Standard init
   */
  init(id: Int, name: String, xCoord: Int, yCoord: Int) {
    let nameAreaTuple = Station.extractNameAndArea(name)
    self.siteId = id
    self.name = nameAreaTuple.name
    self.area = nameAreaTuple.area
    self.cleanName = Station.createCleanName(nameAreaTuple.name)
    self.xCoord = xCoord
    self.yCoord = yCoord
  }
  
  /**
   * Standard init
   */
  init(id: Int, name: String, cleanName: String, area: String, xCoord: Int, yCoord: Int) {
    self.siteId = id
    self.name = name
    self.cleanName = cleanName
    self.area = area
    self.xCoord = xCoord
    self.yCoord = yCoord
  }
  
  /**
   * Extracts the name and area from a search result name.
   * Eg. "Spånga (Stockholm)" = "Spånga" and "Stockholm"
   */
  private static func extractNameAndArea(nameString: String) -> (name: String, area: String) {
    let res = nameString.rangeOfString("(", options: NSStringCompareOptions.BackwardsSearch)
    if let res = res {
      let name = nameString.substringToIndex(res.startIndex)
        .stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
      
      let area = nameString.substringFromIndex(res.startIndex)
        .stringByReplacingOccurrencesOfString("(", withString: "",
          options: NSStringCompareOptions.LiteralSearch, range: nil)
        .stringByReplacingOccurrencesOfString(")", withString: "",
          options: NSStringCompareOptions.LiteralSearch, range: nil)
      
      return (name, area)
    }
    return (nameString, "")
  }
  
  /**
   * Cleans name (removes any additional info from name)
   */
  private static func createCleanName(nameString: String) -> String {
    let res = nameString.rangeOfString("(", options: NSStringCompareOptions.BackwardsSearch)
    if let res = res {
      return nameString.substringToIndex(res.startIndex)
        .stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
    return nameString
  }
  
  // MARK: NSCoding
  
  /**
  * Decoder init
  */
  required convenience init?(coder aDecoder: NSCoder) {
    let siteId = aDecoder.decodeIntegerForKey(PropertyKey.siteId)
    let name = aDecoder.decodeObjectForKey(PropertyKey.name) as! String
    let cleanName = aDecoder.decodeObjectForKey(PropertyKey.cleanName) as! String
    let area = aDecoder.decodeObjectForKey(PropertyKey.area) as! String
    let xCoord = aDecoder.decodeIntegerForKey(PropertyKey.xCoord)
    let yCoord = aDecoder.decodeIntegerForKey(PropertyKey.yCoord)
    
    self.init(id: siteId, name: name, cleanName: cleanName, area: area, xCoord: xCoord, yCoord: yCoord)
  }
  
  /**
   * Encode this object
   */
  func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeInteger(siteId, forKey: PropertyKey.siteId)
    aCoder.encodeObject(name, forKey: PropertyKey.name)
    aCoder.encodeObject(cleanName, forKey: PropertyKey.cleanName)
    aCoder.encodeObject(area, forKey: PropertyKey.area)
    aCoder.encodeInteger(xCoord, forKey: PropertyKey.xCoord)
    aCoder.encodeInteger(yCoord, forKey: PropertyKey.yCoord)
  }
  
  struct PropertyKey {
    static let siteId = "siteId"
    static let name = "name"
    static let cleanName = "cleanName"
    static let area = "area"
    static let xCoord = "xCoord"
    static let yCoord = "yCoord"
  }
}