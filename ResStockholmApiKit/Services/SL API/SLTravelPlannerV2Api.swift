//
//  SLTravelPlannerV2Api.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-23.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation

class SLTravelPlannerV2Api {
  
  let apiKey = "e785e23627434ac295f09e08053147dc"
  let urlBase = "http://api.sl.se/api2/TravelplannerV2/trip.json"
  
  /**
   * Search for trips.
   */
  func tripSearch(
    _ criterions: TripSearchCriterion,
    callback: @escaping ((data: Data?, error: SLNetworkError?)) -> Void) {
      let url = createSimpleSearchApiUrl(criterions)
      HttpRequestHelper.makeGetRequest(url) { resTuple in
        callback(resTuple)        
      }
  }
  
  // MARK: Private methods.
  
  /**
  * Creates api url for simple search
  */
  fileprivate func createSimpleSearchApiUrl(_ criterions: TripSearchCriterion) -> String {    
    let criterionsUrl = generateQueryString(criterions)
    return urlBase + "?key=\(apiKey)\(criterionsUrl)&lang=\(LanguangeHelper.getLangCode())"
  }
  
  /**
   * Query string.
   */
  fileprivate func generateQueryString(_ criterions: TripSearchCriterion) -> String {
    if (
      criterions.origin == nil && criterions.originId == "0") ||
      (criterions.dest == nil && criterions.destId == "0")
    {
      fatalError("TripSearchCriterion: Can not generate query without origin/destination")
    }
    
    var query = "&"
    query += "numTrips=\(criterions.numTrips)"
    
    query += createOriginQuery(criterions)
    query += createDestinationQuery(criterions)
    
    query += (criterions.via != nil) ? "&viaId=\(criterions.via!.siteId!)" : ""
    query += (criterions.date != nil) ? "&date=\(criterions.date!)" : ""
    query += (criterions.time != nil) ? "&time=\(criterions.time!)" : ""
    query += (criterions.numChg > -1) ? "&numChg=\(criterions.numChg)" : ""
    query += (criterions.minChgTime != 0) ? "&minChgTime=\(criterions.minChgTime)" : ""
    
    query += (!criterions.useTrain) ? "&useTrain=0" : ""
    query += (!criterions.useMetro) ? "&useMetro=0" : ""
    query += (!criterions.useTram) ? "&useTram=0" : ""
    query += (!criterions.useBus) ? "&useBus=0" : ""
    query += (!criterions.useFerry) ? "&useFerry=0" : ""
    query += (!criterions.useShip) ? "&useShip=0" : ""
    
    query += (criterions.searchForArrival) ? "&searchForArrival=1" : ""
    query += (criterions.unsharp) ? "&unsharp=1" : ""
    query += "&realtime=true"
    query += (criterions.maxWalkDist > 0) ? "&maxWalkDist=\(criterions.maxWalkDist)" : ""
    query += (criterions.lineInc != nil) ? "&lineInc=\(criterions.lineInc!.trimmingCharacters(in: CharacterSet.whitespaces))" : ""
    query += (criterions.lineExc != nil) ? "&lineExc=\(criterions.lineExc!.trimmingCharacters(in: CharacterSet.whitespaces))" : ""
    
    if let escapedQuery = query.addingPercentEncoding(
      withAllowedCharacters: .urlQueryAllowed) {
      return escapedQuery
    }
    fatalError("Could not encode query string.")
  }
  
  /**
   * Creates a query mathing the origin location
   * type (Station/Address).
   */
  fileprivate func createOriginQuery(_ criterions: TripSearchCriterion) -> String {
    if criterions.origin != nil && criterions.origin?.type == .Current {
      if let currentLocation = MyLocationHelper.sharedInstance.getCurrentLocation() {
        return "&originCoordLat=\(currentLocation.lat!)&originCoordLong=\(currentLocation.lon!)&originCoordName=\(currentLocation.name)"
      }
    }
    
    if criterions.origin == nil {
      return "&originId=\(criterions.originId)"
    } else if criterions.origin!.type == .Station {
      return "&originId=\(criterions.origin!.siteId!)"
    }
    return "&originCoordLat=\(criterions.origin!.lat!)&originCoordLong=\(criterions.origin!.lon!)&originCoordName=\(criterions.origin!.name)"
  }
  
  /**
   * Creates a query mathing the destination location
   * type (Station/Address).
   */
  fileprivate func createDestinationQuery(_ criterions: TripSearchCriterion) -> String {
    if criterions.dest != nil && criterions.dest?.type == .Current {
      if let currentLocation = MyLocationHelper.sharedInstance.getCurrentLocation() {
        return "&destCoordLat=\(currentLocation.lat!)&destCoordLong=\(currentLocation.lon!)&destCoordName=\(currentLocation.name)"
      }
    }
    
    if criterions.dest == nil {
      return "&destId=\(criterions.destId)"
    } else if criterions.dest!.type == .Station {
      return "&destId=\(criterions.dest!.siteId!)"
    }
    
    return "&destCoordLat=\(criterions.dest!.lat!)&destCoordLong=\(criterions.dest!.lon!)&destCoordName=\(criterions.dest!.name)"
  }
}
