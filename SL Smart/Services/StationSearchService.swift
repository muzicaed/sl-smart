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
      let (name, area) = extractNameAndArea(stationJson["Name"].string!)
      let station = Station(
        id: Int(stationJson["SiteId"].string!)!,
        name: name,
        area: area,
        xCoord: Int(stationJson["X"].string!)!,
        yCoord: Int(stationJson["Y"].string!)!
      )
      result.append(station)
    }
    
    return result
  }
  
  /**
   * Extracts the name and area from a search result name.
   * Eg. "Spånga (Stockholm)" = "Spånga" and "Stockholm"
   */
  private func extractNameAndArea(nameString: String) -> (String, String) {
    let res = nameString.rangeOfString("(", options: NSStringCompareOptions.BackwardsSearch)
    if let res = res {
      let name = nameString.substringToIndex(res.startIndex)
        .stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
      
      let area = nameString.substringFromIndex(res.startIndex)
        .stringByReplacingOccurrencesOfString("(", withString: "",
          options: NSStringCompareOptions.LiteralSearch, range: nil)
        .stringByReplacingOccurrencesOfString(")", withString: "",
          options: NSStringCompareOptions.LiteralSearch, range: nil)
      
      return (name, area)
    }
    return (nameString, "")
  }
}