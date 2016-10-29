//
//  Location.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-20.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import CoreLocation

public class Location: NSObject, NSCoding, NSCopying {
  
  public let siteId: String?
  public let name: String
  public let cleanName: String
  public let area: String
  public let type: LocationType
  public let lat: String
  public let lon: String
  public let location: CLLocation
  
  /**
   * Standard init
   */
  public init(id: String?, name: String?, type: String?, lat: String, lon: String) {
    self.lat = Location.convertCoordinateFormat(lat)
    self.lon = Location.convertCoordinateFormat(lon)
    
    self.location = CLLocation(
      latitude: Double(self.lat)!,
      longitude: Double(self.lon)!)
    
    if let type = type {
      if let enumType = LocationType(rawValue: type) {
        self.type = enumType
      } else if let enumType = LocationType(fromShort: type){
        self.type = enumType
      } else {
        self.type = LocationType.Station
      }
    } else {
      self.type = LocationType.Station
    }
    
    if self.type == LocationType.Address || id == nil {
      self.siteId = name
    } else {
      self.siteId = id!
    }
    
    if let name = name {
      let nameAreaTuple = Location.extractNameAndArea(StringUtils.fixBrokenEncoding(Location.ensureUTF8(name)), type: self.type)
      self.name = nameAreaTuple.name
      self.area = nameAreaTuple.area
      self.cleanName = Location.createCleanName(nameAreaTuple.name)
    } else {
      self.name = ""
      self.area = ""
      self.cleanName = ""
    }
  }
  
  /**
   * Standard init
   */
  public init(id: String, name: String, cleanName: String,
              area: String, type: LocationType, lat: String, lon: String) {
    self.siteId = id
    self.name = name
    self.cleanName = cleanName
    self.area = area
    self.type = type
    self.lat = lat
    self.lon = lon
    self.location = CLLocation(
      latitude: Double(self.lat)!,
      longitude: Double(self.lon)!)
  }
  
  /**
   * Creates a current location instance.
   */
  public static func createCurrentLocation() -> Location {
    return Location(id: nil, name: "Nuvarande plats", type: "Current", lat: "0.0", lon: "0.0")
  }
  
  /**
   * Extracts the name and area from a search result name.
   * Eg. "Spånga (Stockholm)" = "Spånga" and "Stockholm"
   */
  private static func extractNameAndArea(
    nameString: String, type: LocationType) -> (name: String, area: String) {
    
    if type == .Station {
      let res = nameString.rangeOfString("(", options: NSStringCompareOptions.BackwardsSearch)
      if let res = res {
        let name = nameString.substringToIndex(res.startIndex)
          .stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        let area = nameString.substringFromIndex(res.startIndex)
          .stringByReplacingOccurrencesOfString("(", withString: "",
            options: NSStringCompareOptions.LiteralSearch, range: nil)
          .stringByReplacingOccurrencesOfString(")", withString: "",
                                                options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        return (name, "\(area) (Hållplats)")
      }
      
    }
    let nameSegments = nameString.characters.split{$0 == ","}.map(String.init)
    if nameSegments.count > 1 {
      return (
        nameSegments[0].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()),
        nameSegments[1].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) + " (Adress)"
      )
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
  
  /**
   * Converts Xpos & Ypos returned from some SL Services
   * into true lat/lon values
   */
  private static func convertCoordinateFormat(coordinate: String) -> String {
    if !coordinate.characters.contains(".") {
      let index = 2
      return String(coordinate.characters.prefix(index)) +
        "." + String(coordinate.characters.suffix(coordinate.characters.count - index))
    }
    return coordinate
  }
  
  /**
   * Ensures the string is UTF8
   */
  private static func ensureUTF8(string: String) -> String {
    var newString = string
    let data = newString.dataUsingEncoding(NSISOLatin1StringEncoding, allowLossyConversion: false)!
    let convertedName = NSString(data: data, encoding: NSUTF8StringEncoding)
    if let convName = convertedName {
      newString = convName as String
    }
    
    return newString
  }
  
  // MARK: NSCoding
  
  /**
   * Decoder init
   */
  required convenience public init?(coder aDecoder: NSCoder) {
    let siteId = aDecoder.decodeObjectForKey(PropertyKey.siteId) as! String
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
    aCoder.encodeObject(siteId, forKey: PropertyKey.siteId)
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
    return Location(
      id: siteId!, name: name, cleanName: cleanName,
      area: area, type: LocationType(rawValue: type.rawValue)!,
      lat: lat, lon: lon)
  }
}

public enum LocationType: String {
  case Station = "Station"
  case Address = "Address"
  case Current = "Current"
  
  init?(fromShort: String) {
    switch fromShort.uppercaseString {
    case "ST":
      self = .Station
    case "ADR":
      self = .Address
    case "CUR":
      self = .Current
    default:
      return nil
    }
  }
}