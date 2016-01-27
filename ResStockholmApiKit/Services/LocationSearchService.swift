//
//  LocationSearchService.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-22.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import CoreLocation

public class LocationSearchService {
  
  private static let api = SLSearchLocationApi()
  private static let nearbyApi = SLSearchNearbyStationsApi()
  
  /**
   * Searches for locations based on the query
   */
  public static func search(
    query: String, stationsOnly: Bool,
    callback: (data: [Location], error: SLNetworkError?) -> Void) {
      api.search(query, stationsOnly: stationsOnly) { resTuple in
        var locations = [Location]()
        if let data = resTuple.data {
          locations = LocationSearchService.convertJsonResponse(data)
          if locations.count == 0 {
            callback(data: locations, error: SLNetworkError.NoDataFound)
            return
          }
        }
        callback(data: locations, error: resTuple.error)
      }
  }
  
  /**
   * Searches for nearby locations.
   */
  public static func searchNearby(
    location: CLLocation,
    callback: (data: [(location: Location, dist: Int)], error: SLNetworkError?) -> Void) {
      nearbyApi.search(location) { resTuple in
        var result = [(location: Location, dist: Int)]()
        if let resData = resTuple.data {
          let data = JSON(data: resData)
          
          if let locationJson = data["LocationList"]["StopLocation"].array {
            for locationJson in locationJson {
              let id = locationJson["id"].string!.stringByReplacingOccurrencesOfString("30010", withString: "")
              let location = Location(
                id: id, name: locationJson["name"].string!, type: "ST",
                lat: locationJson["lat"].string!, lon: locationJson["lon"].string!)
              
              let res = (location: location, dist: Int(locationJson["dist"].string!)!)
              result.append(res)
            }
          } else if let locationJson = data["LocationList"]["StopLocation"].object as? JSON {
            let id = locationJson["id"].string!.stringByReplacingOccurrencesOfString("30010", withString: "")
            let location = Location(
              id: id, name: locationJson["name"].string!, type: "ST",
              lat: locationJson["lat"].string!, lon: locationJson["lon"].string!)
            
            let res = (location: location, dist: Int(locationJson["dist"].string!)!)
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
   * Converts the raw json string into array of Location.
   */
  private static func convertJsonResponse(jsonData: NSData) -> [Location] {
    var result = [Location]()
    let data = JSON(data: jsonData)
    
    for (_,locationJson):(String, JSON) in data["ResponseData"] {
      if !isCodeLocation(locationJson) {
        let location = Location(
          id: locationJson["SiteId"].string!,
          name: locationJson["Name"].string!,
          type: locationJson["Type"].string!,
          lat: locationJson["Y"].string!,
          lon: locationJson["X"].string!
        )
        result.append(location)
      }
      if result.count > 15 {
        break
      }
    }
    
    return result
  }
  
  /**
   * Check if location is "code location" eg. SPA, TERT
   */
  private static func isCodeLocation(locationJson: JSON) -> Bool {
    let name = locationJson["Name"].string!
    if name == name.uppercaseString && name.characters.count < 5 {
      return true
    }
    return false
  }
}