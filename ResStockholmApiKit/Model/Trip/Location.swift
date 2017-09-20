//
//  Location.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-20.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
// TODO: Needs refactoring
//

import Foundation
import CoreLocation

open class Location: NSObject, NSCoding, NSCopying {
  
  open let siteId: String?
  open let name: String
  open let cleanName: String
  open let area: String
  open let type: LocationType
  open let lat: String?
  open let lon: String?
  open let location: CLLocation?
  
  /**
   * Standard init
   */
  public init(id: String?, name: String?, type: String?, lat: String?, lon: String?) {
    if let lat = lat, let lon = lon {
      self.lat = Location.convertCoordinateFormat(lat)
      self.lon = Location.convertCoordinateFormat(lon)
      self.location = CLLocation(
        latitude: Double(lat)!,
        longitude: Double(lon)!)
    } else {
      self.lat = nil
      self.lon = nil
      self.location = nil
    }
    
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
              area: String, type: LocationType, lat: String?, lon: String?) {
    self.siteId = id
    self.name = name
    self.cleanName = cleanName
    self.area = area
    self.type = type
    if let lat = lat, let lon = lon {
      self.lat = lat
      self.lon = lon
      self.location = CLLocation(
        latitude: Double(lat)!,
        longitude: Double(lon)!)
    } else {
      self.lat = nil
      self.lon = nil
      self.location = nil
    }
  }
  
  /**
   * Creates a current location instance.
   */
  open static func createCurrentLocation() -> Location {
    return Location(id: nil, name: "From here".localized, type: "Current", lat: "0.0", lon: "0.0")
  }
  
  /**
   * Extracts the name and area from a search result name.
   * Eg. "Spånga (Stockholm)" = "Spånga" and "Stockholm"
   */
  fileprivate static func extractNameAndArea(
    _ nameString: String, type: LocationType) -> (name: String, area: String) {
    
    if type == .Station {
      let res = nameString.range(of: "(", options: NSString.CompareOptions.backwards)
      if let res = res {
        let name = nameString[..<res.lowerBound]
          .trimmingCharacters(in: CharacterSet.whitespaces)
        
        let area = nameString[..<res.lowerBound]
          .replacingOccurrences(of: "(", with: "",
                                options: NSString.CompareOptions.literal, range: nil)
          .replacingOccurrences(of: ")", with: "",
                                options: NSString.CompareOptions.literal, range: nil)
        
        return (name, "\(area) (\("Stop".localized))")
      }
      
    }
    let nameSegments = nameString.characters.split{$0 == ","}.map(String.init)
    if nameSegments.count > 1 {
      return (
        nameSegments[0].trimmingCharacters(in: CharacterSet.whitespaces),
        nameSegments[1].trimmingCharacters(in: CharacterSet.whitespaces) + " (\("Address".localized))"
      )
    }
    return (nameString, "")
    
  }
  
  /**
   * Cleans name (removes any additional info from name)
   */
  fileprivate static func createCleanName(_ nameString: String) -> String {
    let res = nameString.range(of: "(", options: NSString.CompareOptions.backwards)
    if let res = res {
      return nameString[..<res.lowerBound].trimmingCharacters(in: CharacterSet.whitespaces)
    }
    return nameString
  }
  
  /**
   * Converts Xpos & Ypos returned from some SL Services
   * into true lat/lon values
   */
  fileprivate static func convertCoordinateFormat(_ coordinate: String) -> String {
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
  fileprivate static func ensureUTF8(_ string: String) -> String {
    var newString = string
    let data = newString.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)!
    let convertedName = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
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
    let siteId = aDecoder.decodeObject(forKey: PropertyKey.siteId) as! String
    let name = aDecoder.decodeObject(forKey: PropertyKey.name) as! String
    let cleanName = aDecoder.decodeObject(forKey: PropertyKey.cleanName) as! String
    let area = aDecoder.decodeObject(forKey: PropertyKey.area) as! String
    let type = aDecoder.decodeObject(forKey: PropertyKey.type) as! String
    let lat = aDecoder.decodeObject(forKey: PropertyKey.lat) as! String
    let lon = aDecoder.decodeObject(forKey: PropertyKey.lon) as! String
    
    self.init(
      id: siteId, name: name, cleanName: cleanName,
      area: area, type: LocationType(rawValue: type)!,
      lat: lat, lon: lon)
  }
  
  /**
   * Encode this object
   */
  open func encode(with aCoder: NSCoder) {
    aCoder.encode(siteId, forKey: PropertyKey.siteId)
    aCoder.encode(name, forKey: PropertyKey.name)
    aCoder.encode(cleanName, forKey: PropertyKey.cleanName)
    aCoder.encode(area, forKey: PropertyKey.area)
    aCoder.encode(type.rawValue, forKey: PropertyKey.type)
    aCoder.encode(lat, forKey: PropertyKey.lat)
    aCoder.encode(lon, forKey: PropertyKey.lon)
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
  open func copy(with zone: NSZone?) -> Any {
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
    switch fromShort.uppercased() {
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
