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
  
  public var originId: Int
  public var destId: Int
  public var date: String?
  public var time: String?
  public var numChg: Int?
  public var minChgTime: Int?
  public var lineInc: String?
  public var lineExc: String?
  public var searchForArrival = false
  public var unsharp = false
  public var maxWalkDist = 300
  
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
  public init(originId: Int, destId: Int) {
    self.originId = originId
    self.destId = destId
  }
  
  convenience public init(origin: Station, destination: Station) {
    self.init(originId: origin.siteId, destId: destination.siteId)
  }
  
  /**
   * Query string.
   */
  public func generateQueryString(beginsWithQuestionMark: Bool) -> String {
    var query = (beginsWithQuestionMark) ? "?" : "&"
    query += "originId=\(originId)&destId=\(destId)&numTrips=\(numTrips)"
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
      .URLHostAllowedCharacterSet()) {
        return escapedQuery
    }
    fatalError("Could not encode query string.")
  }
}