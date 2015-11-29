//
//  StationSearchService.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-22.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import CoreLocation

class StationSearchService {
  
  private static let api = SLSearchStationApi()
  private static let nearbyApi = SLSearchNearbyStationsApi()
  
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
  static func searchNearby(location: CLLocation, callback: ([(id: Int, dist: Int)]) -> Void) {
    nearbyApi.search(location) { jsonData in
      var result = [(id: Int, dist: Int)]()
      let data = JSON(data: jsonData)
      
      print(data)
      
      if let locationJson = data["LocationList"]["StopLocation"].array {
        for locationJson in locationJson {
          let id = locationJson["id"].string!.stringByReplacingOccurrencesOfString("30010", withString: "")
          let res = (id: Int(id)!, dist: Int(locationJson["dist"].string!)!)
          result.append(res)
        }
      } else if let locationJson = data["LocationList"]["StopLocation"].object as? JSON {
        let id = locationJson["id"].string!.stringByReplacingOccurrencesOfString("30010", withString: "")
        let res = (id: Int(id)!, dist: Int(locationJson["dist"].string!)!)
        result.append(res)
      }
      
      callback(result)
    }
  }
  
  /**
   * Converts the raw json string into array of Station.
   */
  private static func convertJsonResponse(jsonData: NSData) -> [Station] {
    var result = [Station]()
    let data = JSON(data: jsonData)
    
    print(data)
    for (_,stationJson):(String, JSON) in data["ResponseData"] {
      let station = Station(
        id: Int(stationJson["SiteId"].string!)!,
        name: stationJson["Name"].string!)
      result.append(station)
    }
    
    return result
  }
}