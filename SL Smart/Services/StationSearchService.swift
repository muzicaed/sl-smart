//
//  StationSearchService.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-22.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation

class StationSearchService {
  
  private static let api = SLSearchStationApi()
  
  /**
   * Searches for stations based on the query
   */
  static func search(query: String, callback: ([Station]) -> Void) {
    api.search(query) { data in
      let stations = StationSearchService.convertJsonResponse(data)
      callback(stations)
    }
  }
  
  /**
   * Searches for nearby stations.
   */
  static func searchNearby() -> [Station] {
    return [Station]()
  }
  
  /**
   * Converts the raw json string into array of Station.
   */
  private static func convertJsonResponse(jsonDataString: NSData) -> [Station] {
    var result = [Station]()
    let data = JSON(data: jsonDataString)

    for (_,stationJson):(String, JSON) in data["ResponseData"] {
      let station = Station(
        id: Int(stationJson["SiteId"].string!)!,
        name: stationJson["Name"].string!,
        xCoord: Int(stationJson["X"].string!)!,
        yCoord: Int(stationJson["Y"].string!)!
      )
      result.append(station)
    }
    
    return result
  }
}