//
//  StationSearchService.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-22.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation

class StationSearchService {
  
  // Singelton pattern
  static let sharedInstance = StationSearchService()
  private let api = SLSearchStationApi()
  
  /**
   * Searches for stations based on the query
   */
  func search(query: String, callback: ([Station]) -> Void) {
    api.search(query) { data in
      let stations = self.convertJsonResponse(data)
      callback(stations)
    }
  }
  
  /**
   * Converts the raw json string into array of Station.
   */
  private func convertJsonResponse(jsonDataString: NSData) -> [Station] {
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