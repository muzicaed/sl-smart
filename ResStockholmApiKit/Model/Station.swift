//
//  Station.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-20.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation

public class Station: NSObject, NSCoding, NSCopying {
  
  public let siteId: Int
  public let name: String
  public let cleanName: String
  public let area: String
  public let type: LocationType
  public let lat: String
  public let lon: String
  
  /**
   * Standard init
   */
  public init(id: Int, name: String, type: String, lat: String, lon: String) {
    let nameAreaTuple = Station.extractNameAndArea(name)
    self.siteId = id
    self.name = nameAreaTuple.name
    self.area = nameAreaTuple.area
    self.cleanName = Station.createCleanName(nameAreaTuple.name)
    self.lat = lat
    self.lon = lon
    if let enumType = LocationType(rawValue: type) {
      self.type = enumType
    } else if let enumType = LocationType(fromShort: type){
      self.type = enumType
    } else {
      self.type = LocationType.Station
    }
  }
  
  /**
   * Standard init
   */
  public init(id: Int, name: String, cleanName: String,
    area: String, type: LocationType, lat: String, lon: String) {
      self.siteId = id
      self.name = name
      self.cleanName = cleanName
      self.area = area
      self.type = type
      self.lat = lat
      self.lon = lon
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
  required convenience public init?(coder aDecoder: NSCoder) {
    let siteId = aDecoder.decodeIntegerForKey(PropertyKey.siteId)
    let name = aDecoder.decodeObjectForKey(PropertyKey.name) as! String
    let cleanName = aDecoder.decodeObjectForKey(PropertyKey.cleanName) as! String
    let area = aDecoder.decodeObjectForKey(PropertyKey.area) as! String
    let type = aDecoder.decodeObjectForKey(PropertyKey.type) as! String
    let lat = aDecoder.decodeObjectForKey(PropertyKey.lat) as! String
    let lon = aDecoder.decodeObjectForKey(PropertyKey.lon) as! String
    
    self.init(
      id: siteId, name: name, cleanName: cleanName,
      area: area, type: LocationType(rawValue: type)!,
      lat: lat, lon: lon)
  }
  
  /**
   * Encode this object
   */
  public func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeInteger(siteId, forKey: PropertyKey.siteId)
    aCoder.encodeObject(name, forKey: PropertyKey.name)
    aCoder.encodeObject(cleanName, forKey: PropertyKey.cleanName)
    aCoder.encodeObject(area, forKey: PropertyKey.area)
    aCoder.encodeObject(type.rawValue, forKey: PropertyKey.type)
    aCoder.encodeObject(lat, forKey: PropertyKey.lat)
    aCoder.encodeObject(lon, forKey: PropertyKey.lon)
  }
  
  struct PropertyKey {
    static let siteId = "siteId"
    static let name = "name"
    static let cleanName = "cleanName"
    static let area = "area"
    static let type = "type"
    static let lat = "lat"
    static let lon = "lon"
  }
  
  // MARK: NSCopying
  
  /**
  * Copy self
  */
  public func copyWithZone(zone: NSZone) -> AnyObject {
    return Station(
      id: siteId, name: name, cleanName: cleanName,
      area: area, type: LocationType(rawValue: type.rawValue)!,
      lat: lat, lon: lon)
  }
}

public enum LocationType: String {
  case Station = "Station"
  case Address = "Address"
  
  init?(fromShort: String) {
    switch fromShort.uppercaseString {
    case "ST":
      self = .Station
    case "ADR":
      self = .Address
    default:
      return nil
    }
  }
}