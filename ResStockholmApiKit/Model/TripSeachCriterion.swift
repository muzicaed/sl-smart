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
public class TripSearchCriterion {

  public var originId = 0
  public var destId = 0
  public var origin: Location?
  public var viaId: Int?
  public var dest: Location?
  public var date: String?
  public var time: String?
  public var numChg: Int?
  public var minChgTime: Int?
  public var lineInc: String?
  public var lineExc: String?
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

    query += (viaId != nil) ? "&viaId=\(viaId!)" : ""
    query += (date != nil) ? "&date=\(date!)" : ""
    query += (time != nil) ? "&time=\(time!)" : ""
    query += (numChg != nil) ? "&numChg=\(numChg!)" : ""
    query += (minChgTime != nil) ? "&minChgTime=\(minChgTime!)" : ""
    query += (lineInc != nil) ? "&lineInc=\(lineInc!)" : ""
    query += (lineExc != nil) ? "&lineExc=\(lineExc!)" : ""
    
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