//
//  StationSearchService.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-22.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import CoreLocation

public class StationSearchService {
  
  private static let api = SLSearchStationApi()
  private static let nearbyApi = SLSearchNearbyStationsApi()
  
  /**
   * Searches for stations based on the query
   */
  public static func search(
    query: String,
    callback: (data: [Station], error: SLNetworkError?) -> Void) {
      api.search(query, stationsOnly: true) { resTuple in
        var stations = [Station]()
        if let data = resTuple.data {
          stations = StationSearchService.convertJsonResponse(data)
          if stations.count == 0 {
            callback(data: stations, error: SLNetworkError.NoDataFound)
            return
          }
        }
        callback(data: stations, error: resTuple.error)
      }
  }
  
  /**
   * Searches for nearby stations.
   */
  public static func searchNearby(
    location: CLLocation,
    callback: (data: [(id: Int, dist: Int)], error: SLNetworkError?) -> Void) {
      nearbyApi.search(location) { resTuple in
        var result = [(id: Int, dist: Int)]()
        if let resData = resTuple.data {
          let data = JSON(data: resData)
          
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
        }
        
        if result.count == 0 {
          callback(data: result, error: SLNetworkError.NoDataFound)
          return
        }
        callback(data: result, error: resTuple.error)
      }
  }
  
  /**
   * Converts the raw json string into array of Station.
   */
  private static func convertJsonResponse(jsonData: NSData) -> [Station] {
    var result = [Station]()
    let data = JSON(data: jsonData)
    
    for (_,stationJson):(String, JSON) in data["ResponseData"] {
      let station = Station(
        id: Int(stationJson["SiteId"].string!)!,
        name: stationJson["Name"].string!,
        type: stationJson["Type"].string!,
        lat: "NOT_SUPPORTED", // TODO: Convert into right lat format
        lon: "NOT_SUPPORTED" // TODO: Convert into right long format
      )
      result.append(station)
    }
    
    return result
  }
}