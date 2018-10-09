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
open class TripSearchCriterion: NSObject, NSCoding, NSCopying {

  open var originId = "0"
  open var destId = "0"
  open var origin: Location?
  open var dest: Location?
  open var via: Location?
  open var date: String?
  open var time: String?
  open var numChg = -1
  open var minChgTime = 0
  open var searchForArrival = false
  open var unsharp = false
  open var maxWalkDist = 1000
  
  open var useTrain = true
  open var useMetro = true
  open var useTram = true
  open var useBus = true
  open var useFerry = true
  open var useShip = true
  
  open var numTrips = 15
  open var realtime = true
  
  open var isAdvanced = false
  
  open var lineInc: String?
  open var lineExc: String?
  
  
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
  public init(originId: String, destId: String) {
    self.originId = originId
    self.destId = destId
  }
  
  /**
   * Query string.
   */
  open func generateQueryString(_ beginsWithQuestionMark: Bool) -> String {
    if (origin == nil && originId == "0") || (dest == nil && destId == "0") {
      fatalError("TripSearchCriterion: Can not generate query without origin/destination")
    }
    
    var query = (beginsWithQuestionMark) ? "?" : "&"
    
    query += createOriginQuery()
    query += createDestinationQuery()

    query += (via != nil) ? "&viaId=\(via!.siteId!)" : ""
    query += (date != nil) ? "&date=\(date!)" : ""
    query += (time != nil) ? "&time=\(time!)" : ""
    query += (numChg > -1) ? "&maxChange=\(numChg)" : ""
    query += (minChgTime != 0) ? "&minChangeTime=\(minChgTime)" : ""
    
    let productBitMask = createProductBitMask()
    if (productBitMask != "0") {
        query += "&products=\(productBitMask)"
    }
    
    query += (searchForArrival) ? "&searchForArrival=1" : ""
    query += "&numB=0"
    query += "&numF=6"
    query += (maxWalkDist > 0) ? "&originWalk=1,0,\(maxWalkDist)" : ""
    query += (maxWalkDist > 0) ? "&destWalk=1,0,\(maxWalkDist)" : ""
    
    
    query += (lineInc != nil) ? "&lines=\(lineInc!.trimmingCharacters(in: CharacterSet.whitespaces))" : ""
    query += (lineExc != nil) ? "&lines=!\(lineExc!.trimmingCharacters(in: CharacterSet.whitespaces))" : ""
    
    if let escapedQuery = query.addingPercentEncoding(
      withAllowedCharacters: .urlQueryAllowed) {
        return escapedQuery
    }
    fatalError("Could not encode query string.")
  }
  
  /**
   * Resets advanced search criterions
   */
  open func resetAdvancedTripTypes() {
    isAdvanced = (via != nil)
    useTrain = true
    useMetro = true
    useTram = true
    useBus = true
    useFerry = true
    useShip = true
    maxWalkDist = 1000
    numChg = -1
    minChgTime = 0
    unsharp = false
    lineInc = nil
    lineExc = nil
  }
  
  /**
   * Gets smart id.
   */
  open func smartId() -> String{
    if (origin == nil && originId == "0") || (dest == nil && destId == "0") {
      fatalError("Can not generate smart id without origin/destination")
    }
    var viaStr = ""
    if let via = self.via {
      viaStr = "\(via.siteId!)"
    }    
    return "smart-\(createOriginQuery())-\(viaStr)-\(createDestinationQuery())"
  }
  
  // MARK: NSCoding
  
  required public init?(coder aDecoder: NSCoder) {
    self.originId = aDecoder.decodeObject(forKey: PropertyKey.originId) as! String
    self.destId = aDecoder.decodeObject(forKey: PropertyKey.destId) as! String
    self.origin = aDecoder.decodeObject(forKey: PropertyKey.origin) as! Location?
    self.dest = aDecoder.decodeObject(forKey: PropertyKey.dest) as! Location?
    self.via = aDecoder.decodeObject(forKey: PropertyKey.via) as! Location?
    self.date = aDecoder.decodeObject(forKey: PropertyKey.date) as! String?
    self.time = aDecoder.decodeObject(forKey: PropertyKey.time) as! String?
    self.numChg = aDecoder.decodeInteger(forKey: PropertyKey.numChg)
    self.minChgTime = aDecoder.decodeInteger(forKey: PropertyKey.minChgTime)
    self.searchForArrival = aDecoder.decodeBool(forKey: PropertyKey.searchForArrival)
    self.unsharp = aDecoder.decodeBool(forKey: PropertyKey.unsharp)
    self.maxWalkDist = aDecoder.decodeInteger(forKey: PropertyKey.maxWalkDist)
    self.useTrain = aDecoder.decodeBool(forKey: PropertyKey.useTrain)
    self.useMetro = aDecoder.decodeBool(forKey: PropertyKey.useMetro)
    self.useTram = aDecoder.decodeBool(forKey: PropertyKey.useTram)
    self.useBus = aDecoder.decodeBool(forKey: PropertyKey.useBus)
    self.useFerry = aDecoder.decodeBool(forKey: PropertyKey.useFerry)
    self.useShip = aDecoder.decodeBool(forKey: PropertyKey.useShip)
    self.numTrips = aDecoder.decodeInteger(forKey: PropertyKey.numTrips)
    self.realtime = aDecoder.decodeBool(forKey: PropertyKey.realtime)
    self.isAdvanced = aDecoder.decodeBool(forKey: PropertyKey.isAdvanced)
    self.lineInc = aDecoder.decodeObject(forKey: PropertyKey.lineInc) as! String?
    self.lineExc = aDecoder.decodeObject(forKey: PropertyKey.lineExc) as! String?
  }
  
  /**
   * Encode this object
   */
  open func encode(with aCoder: NSCoder) {
    aCoder.encode(originId, forKey: PropertyKey.originId)
    aCoder.encode(destId, forKey: PropertyKey.destId)
    aCoder.encode(origin, forKey: PropertyKey.origin)
    aCoder.encode(dest, forKey: PropertyKey.dest)
    aCoder.encode(via, forKey: PropertyKey.via)
    aCoder.encode(date, forKey: PropertyKey.date)
    aCoder.encode(time, forKey: PropertyKey.time)
    aCoder.encode(numChg, forKey: PropertyKey.numChg)
    aCoder.encode(minChgTime, forKey: PropertyKey.minChgTime)
    aCoder.encode(searchForArrival, forKey: PropertyKey.searchForArrival)
    aCoder.encode(unsharp, forKey: PropertyKey.unsharp)
    aCoder.encode(maxWalkDist, forKey: PropertyKey.maxWalkDist)
    aCoder.encode(useTrain, forKey: PropertyKey.useTrain)
    aCoder.encode(useMetro, forKey: PropertyKey.useMetro)
    aCoder.encode(useTram, forKey: PropertyKey.useTram)
    aCoder.encode(useBus, forKey: PropertyKey.useBus)
    aCoder.encode(useFerry, forKey: PropertyKey.useFerry)
    aCoder.encode(useShip, forKey: PropertyKey.useShip)
    aCoder.encode(numTrips, forKey: PropertyKey.numTrips)
    aCoder.encode(realtime, forKey: PropertyKey.realtime)
    aCoder.encode(isAdvanced, forKey: PropertyKey.isAdvanced)
    aCoder.encode(lineInc, forKey: PropertyKey.lineInc)
    aCoder.encode(lineExc, forKey: PropertyKey.lineExc)
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
    static let lineInc = "lineInc"
    static let lineExc = "lineExc"
  }
  
  // MARK: NSCopying
  
  /**
  * Copy self
  */
  open func copy(with zone: NSZone?) -> Any {
    let copy = TripSearchCriterion(
      origin: self.origin?.copy() as! Location?,
      dest: self.dest?.copy() as! Location?)
    
    copy.originId = originId
    copy.destId = destId
    copy.via = via?.copy() as! Location?
    copy.date = date
    copy.time = time
    copy.numChg = numChg
    copy.minChgTime = minChgTime
    copy.searchForArrival = searchForArrival
    copy.unsharp = unsharp
    copy.maxWalkDist = maxWalkDist
    copy.useTrain = useTrain
    copy.useMetro = useMetro
    copy.useTram = useTram
    copy.useBus = useBus
    copy.useFerry = useFerry
    copy.useShip = useShip
    copy.numTrips = numTrips
    copy.realtime = realtime
    copy.isAdvanced = isAdvanced
    copy.lineInc = lineInc
    copy.lineExc = lineExc

    return copy
  }
  
  // MARK: Private methods
  
  /**
   * Creates a query mathing the origin location
   * type (Station/Address).
   */
  fileprivate func createOriginQuery() -> String {
    if origin != nil && origin?.type == .Current {
      if let currentLocation = MyLocationHelper.sharedInstance.getCurrentLocation() {
        return "&originCoordLat=\(currentLocation.lat!)&originCoordLong=\(currentLocation.lon!)&originCoordName=\(currentLocation.name)"
      }
    }
    
    if origin == nil {
      return "&originExtId=\(originId)"
    } else if origin!.type == .Station {
      return "&originExtId=\(origin!.siteId!)"
    }
    return "&originCoordLat=\(origin!.lat!)&originCoordLong=\(origin!.lon!)&originCoordName=\(origin!.name)"
  }
  
  /**
   * Creates a query mathing the destination location
   * type (Station/Address).
   */
  fileprivate func createDestinationQuery() -> String {
    if dest != nil && dest?.type == .Current {
      if let currentLocation = MyLocationHelper.sharedInstance.getCurrentLocation() {
        return "&destCoordLat=\(currentLocation.lat!)&destCoordLong=\(currentLocation.lon!)&destCoordName=\(currentLocation.name)"
      }
    }
    
    if dest == nil {
      return "&destExtId=\(destId)"
    } else if dest!.type == .Station {
      return "&destExtId=\(dest!.siteId!)"
    }

    return "&destCoordLat=\(dest!.lat!)&destCoordLong=\(dest!.lon!)&destCoordName=\(dest!.name)"
  }
    
    fileprivate func createProductBitMask() -> String {
        var productMask = 0
        
        if (useTrain) { productMask += 1 }
        if (useMetro) { productMask += 2 }
        if (useTram) { productMask += 4 }
        if (useBus) { productMask += 8 }
        if (useFerry || useShip) { productMask += 64 }
        
        return String(productMask)
    }
}
