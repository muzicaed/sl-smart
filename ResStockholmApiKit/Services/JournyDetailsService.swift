//
//  JournyDetailsService.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-01-15.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation

public class JournyDetailsService {
  
  private static let api = SLJourneyDetailsApi()
  
  /**
   * Fetch journy details
   */
  public static func fetchJournyDetails(urlEncRef: String,
    callback: (data: [Stop], error: SLNetworkError?) -> Void) {
      var result = [Stop]()
      api.getDetails(urlEncRef) { (data, error) -> Void in
        if let d = data {
          if d.length == 0 {
            callback(data: result, error: SLNetworkError.NoDataFound)
            return
          }
          
          let jsonData = JSON(data: d)          
          if jsonData["JourneyDetail"].isExists() {
            if let stopsJson = jsonData["JourneyDetail"]["Stops"]["Stop"].array {
              for stopJson in stopsJson {
                result.append(convertStopJson(stopJson))
              }
            }
          }
        }
        callback(data: result, error: error)
      }
  }
  
  /**
   * Filter out to show only relevat
   * in between stops.
   */
  public static func filterStops(stops: [Stop], segment: TripSegment) -> [Stop] {
    var filterStops = [Stop]()
    var foundFirst = false
    for stop in stops {
      if foundFirst && stop.id == segment.destination.siteId! {
        filterStops.append(stop)
        break
      } else if foundFirst {
        filterStops.append(stop)
      } else if stop.id == segment.origin.siteId! {
        filterStops.append(stop)
        foundFirst = true
      }
    }
    
    return filterStops
  }
  
  // MARK: Private
  
  /**
  * Converts the raw json string into array of Stops.
  */
  private static func convertStopJson(stopJson: JSON) -> Stop {
    let timeDateTuple = extractTimeDate(stopJson)
    
    return Stop(
      id: stopJson["id"].string!,
      depDate: timeDateTuple.depDate,
      depTime: timeDateTuple.depTime)
  }
  
  /**
   * Extracts departure date/time and arriaval date/time.
   * Uses realtime data if available.
   */
  private static func extractTimeDate(stopJson: JSON)
    -> (depDate: String?, depTime: String?) {

      var depDate = stopJson["depDate"].string
      var depTime = stopJson["depTime"].string
      
      if let rtDate = stopJson["rtDepDate"].string {
        depDate = rtDate
      }
      if let rtTime = stopJson["rtDepTime"].string {
        depTime = rtTime
      }
      
      return (depDate, depTime)
  }
}
