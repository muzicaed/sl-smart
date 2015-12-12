//
//  TripSeachCriterion.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-26.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation

/**
 * Simple data object.
 */
public class TripSearchCriterion: NSObject, NSCoding {

  public var originId = 0
  public var destId = 0
  public var origin: Location?
  public var dest: Location?
  public var via: Location?
  public var date: String?
  public var time: String?
  public var numChg = 0
  public var minChgTime = 0
  public var searchForArrival = false
  public var unsharp = false
  public var maxWalkDist = 1000
  
  public var useTrain = true
  public var useMetro = true
  public var useTram = true
  public var useBus = true
  public var useFerry = true
  public var useShip = true
  
  public var numTrips = 8
  public var realtime = false
  
  public var isAdvanced = false
  
  
  /**
   * Standard init
   */
  public init(origin: Location?, dest: Location?) {
    self.origin = origin
    self.dest = dest
  }
  
  /**
   * Standard init
   */
  public init(originId: Int, destId: Int) {
    self.originId = originId
    self.destId = destId
  }
  
  /**
   * Query string.
   */
  public func generateQueryString(beginsWithQuestionMark: Bool) -> String {
    if (origin == nil && originId == 0) || (dest == nil && destId == 0) {
      fatalError("TripSearchCriterion: Can not generate query without origin/destination")
    }
    
    var query = (beginsWithQuestionMark) ? "?" : "&"
    query += "numTrips=\(numTrips)"
    
    query += createOriginQuery()
    query += createDestinationQuery()

    query += (via != nil) ? "&viaId=\(via!.siteId)" : ""
    query += (date != nil) ? "&date=\(date!)" : ""
    query += (time != nil) ? "&time=\(time!)" : ""
    query += (numChg != 0) ? "&numChg=\(numChg)" : ""
    query += (minChgTime != 0) ? "&minChgTime=\(minChgTime)" : ""
    
    query += (!useTrain) ? "&useTrain=0" : ""
    query += (!useMetro) ? "&useMetro=0" : ""
    query += (!useTram) ? "&useTram=0" : ""
    query += (!useBus) ? "&useBus=0" : ""
    query += (!useFerry) ? "&useFerry=0" : ""
    query += (!useShip) ? "&useShip=0" : ""
    
    query += (searchForArrival) ? "&searchForArrival=1" : ""
    query += (unsharp) ? "&unsharp=1" : ""
    query += (realtime) ? "&realtime=true" : ""
    query += (maxWalkDist > 0) ? "&maxWalkDist=\(maxWalkDist)" : ""
    
    if let escapedQuery = query.stringByAddingPercentEncodingWithAllowedCharacters(
      .URLQueryAllowedCharacterSet()) {
        return escapedQuery
    }
    fatalError("Could not encode query string.")
  }
  
  // MARK: NSCoding
  
  required public init?(coder aDecoder: NSCoder) {
    self.originId = aDecoder.decodeIntegerForKey(PropertyKey.originId)
    self.destId = aDecoder.decodeIntegerForKey(PropertyKey.destId)
    self.origin = aDecoder.decodeObjectForKey(PropertyKey.origin) as! Location?
    self.dest = aDecoder.decodeObjectForKey(PropertyKey.dest) as! Location?
    self.via = aDecoder.decodeObjectForKey(PropertyKey.via) as! Location?
    self.date = aDecoder.decodeObjectForKey(PropertyKey.date) as! String?
    self.time = aDecoder.decodeObjectForKey(PropertyKey.time) as! String?
    self.numChg = aDecoder.decodeIntegerForKey(PropertyKey.numChg)
    self.minChgTime = aDecoder.decodeIntegerForKey(PropertyKey.minChgTime)
    self.searchForArrival = aDecoder.decodeBoolForKey(PropertyKey.searchForArrival)
    self.unsharp = aDecoder.decodeBoolForKey(PropertyKey.unsharp)
    self.maxWalkDist = aDecoder.decodeIntegerForKey(PropertyKey.maxWalkDist)
    self.useTrain = aDecoder.decodeBoolForKey(PropertyKey.useTrain)
    self.useMetro = aDecoder.decodeBoolForKey(PropertyKey.useMetro)
    self.useTram = aDecoder.decodeBoolForKey(PropertyKey.useTram)
    self.useBus = aDecoder.decodeBoolForKey(PropertyKey.useBus)
    self.useFerry = aDecoder.decodeBoolForKey(PropertyKey.useFerry)
    self.useShip = aDecoder.decodeBoolForKey(PropertyKey.useShip)
    self.numTrips = aDecoder.decodeIntegerForKey(PropertyKey.numTrips)
    self.realtime = aDecoder.decodeBoolForKey(PropertyKey.realtime)
    self.isAdvanced = aDecoder.decodeBoolForKey(PropertyKey.isAdvanced)
  }
  
  /**
   * Encode this object
   */
  public func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeInteger(originId, forKey: PropertyKey.originId)
    aCoder.encodeInteger(destId, forKey: PropertyKey.destId)
    aCoder.encodeObject(origin, forKey: PropertyKey.origin)
    aCoder.encodeObject(dest, forKey: PropertyKey.dest)
    aCoder.encodeObject(via, forKey: PropertyKey.via)
    aCoder.encodeObject(date, forKey: PropertyKey.date)
    aCoder.encodeObject(time, forKey: PropertyKey.time)
    aCoder.encodeInteger(numChg, forKey: PropertyKey.numChg)
    aCoder.encodeInteger(minChgTime, forKey: PropertyKey.minChgTime)
    aCoder.encodeBool(searchForArrival, forKey: PropertyKey.searchForArrival)
    aCoder.encodeBool(unsharp, forKey: PropertyKey.unsharp)
    aCoder.encodeInteger(maxWalkDist, forKey: PropertyKey.maxWalkDist)
    aCoder.encodeBool(useTrain, forKey: PropertyKey.useTrain)
    aCoder.encodeBool(useMetro, forKey: PropertyKey.useMetro)
    aCoder.encodeBool(useTram, forKey: PropertyKey.useTram)
    aCoder.encodeBool(useBus, forKey: PropertyKey.useBus)
    aCoder.encodeBool(useFerry, forKey: PropertyKey.useFerry)
    aCoder.encodeBool(useShip, forKey: PropertyKey.useShip)
    aCoder.encodeInteger(numTrips, forKey: PropertyKey.numTrips)
    aCoder.encodeBool(realtime, forKey: PropertyKey.realtime)
    aCoder.encodeBool(isAdvanced, forKey: PropertyKey.isAdvanced)
  }
  
  struct PropertyKey {
    static let originId = "originId"
    static let destId = "destId"
    static let origin = "origin"
    static let dest = "dest"
    static let via = "via"
    static let date = "date"
    static let time = "time"
    static let numChg = "numChg"
    static let minChgTime = "minChgTime"
    static let searchForArrival = "searchForArrival"
    static let unsharp = "unsharp"
    static let maxWalkDist = "maxWalkDist"
    static let useTrain = "useTrain"
    static let useMetro = "useMetro"
    static let useTram = "useTram"
    static let useBus = "useBus"
    static let useFerry = "useFerry"
    static let useShip = "useShip"
    static let numTrips = "numTrips"
    static let realtime = "realtime"
    static let isAdvanced = "isAdvanced"
  }
  
  // MARK: Private methods
  
  /**
   * Creates a query mathing the origin location
   * type (Station/Address).
   */
  private func createOriginQuery() -> String {
    if origin == nil {
      return "&originId=\(originId)"
    } else if origin!.type == .Station {
      return "&originId=\(origin!.siteId)"
    }
    return "&originCoordLat=\(origin!.lat)&originCoordLong=\(origin!.lon)&originCoordName=\(origin!.name)"
  }
  
  /**
   * Creates a query mathing the destination location
   * type (Station/Address).
   */
  private func createDestinationQuery() -> String {
    if dest == nil {
      return "&destId=\(destId)"
    } else if dest!.type == .Station {
      return "&destId=\(dest!.siteId)"
    }

    return "&destCoordLat=\(dest!.lat)&destCoordLong=\(dest!.lon)&destCoordName=\(dest!.name)"
  }
}