//
//  JournyDetailsService.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-01-15.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation
import CoreLocation

open class JournyDetailsService {
  
  fileprivate static let api = SLJourneyDetailsApi()
  
  /**
   * Fetch journy details
   */
  open static func fetchJournyDetails(_ urlEncRef: String,
                                      callback: @escaping (_ data: [Stop], _ error: SLNetworkError?) -> Void) {
    var result = [Stop]()
    api.getDetails(urlEncRef) { (arg) -> Void in
      
      let (data, error) = arg
      if let d = data {
        if d.count == 0 {
          HttpRequestHelper.clearCache()
          callback(result, SLNetworkError.noDataFound)
          return
        }
        
        let jsonData = JSON(data: d)
        if let stopsJson = jsonData["Stops"]["Stop"].array {
          for stopJson in stopsJson {
            result.append(convertStopJson(stopJson))
          }
        }
      }
      callback(result, error)
    }
  }
  
  /**
   * Filter out to show only relevat
   * in between stops.
   */
  open static func filterStops(_ stops: [Stop], segment: TripSegment) -> [Stop] {
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
  fileprivate static func convertStopJson(_ stopJson: JSON) -> Stop {
    let timeDateTuple = extractTimeDate(stopJson)
    
    if let staticStop = StopsStore.sharedInstance.getOnId(stopJson["extId"].string!) {
      return Stop(
        id: stopJson["extId"].string!, name: staticStop.stopPointName,
        location: staticStop.location, type: staticStop.type,
        exits: staticStop.exits, depDate: timeDateTuple.depDate, depTime: timeDateTuple.depTime)
    }
    print(stopJson)
    return Stop(
      id: stopJson["extId"].string!, name: stopJson["name"].string!,
      location: CLLocation(latitude: stopJson["lat"].double!, longitude: stopJson["lon"].double!),
      type: .Bus, exits: [StaticExit](), depDate: timeDateTuple.depDate,
      depTime: timeDateTuple.depTime)
  }
  
  /**
   * Extracts departure date/time and arriaval date/time.
   * Uses realtime data if available.
   */
  fileprivate static func extractTimeDate(_ stopJson: JSON)
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
