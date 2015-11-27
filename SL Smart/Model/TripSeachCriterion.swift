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
class TripSearchCriterion {
  
  let originId: Int
  let destId: Int
  var date: String?
  var time: String?
  var numChg: Int?
  var minChgTime: Int?
  var lineInc: String?
  var lineExc: String?
  var searchForArrival = false
  var unsharp = false
  var maxWalkDist = 300
  
  var useTrain = true
  var useMetro = true
  var useTram = true
  var useBus = true
  var useFerry = true
  var useShip = true
  
  var numTrips = 6
  var realtime = false
  
  
  /**
   * Standard init
   */
  init(originId: Int, destId: Int) {
    self.originId = originId
    self.destId = destId
  }
  
  convenience init(origin: Station, destination: Station) {
    self.init(originId: origin.siteId, destId: destination.siteId)
  }
  
  /**
   * Query string.
   */
  func generateQueryString(beginsWithQuestionMark: Bool) -> String {
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