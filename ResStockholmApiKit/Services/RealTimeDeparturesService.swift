//
//  RealTimeDeparturesService.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-01-19.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation
import CoreLocation

public class RealTimeDeparturesService {
  
  private static let api = SLRealtimeDepartures()
  
  /**
   * Fetch geometry data
   */
  public static func fetch(siteId: Int,
    callback: (data: RealTimeDepartures?, error: SLNetworkError?) -> Void) {
      api.getRealTimeTable(siteId) { (data, error) -> Void in
        if let d = data {
          if d.length == 0 {
            print("Error...")
            callback(data: nil, error: SLNetworkError.NoDataFound)
            return
          }
          
          let jsonData = JSON(data: d)
          let result = convertJson(jsonData["ResponseData"])
          callback(data: result, error: error)
          return
        }
        
        callback(data: nil, error: error)
      }
  }
  
  // MARK: Private
  
  /**
  * Converts the raw json string into array of Location.
  */
  private static func convertJson(json: JSON) -> RealTimeDepartures {
    
    let buses = convertBusesJson(json["Buses"])
    
    let departures = RealTimeDepartures(
      lastUpdated: json["LatestUpdate"].string!,
      dataAge: json["DataAge"].int!)
    
    departures.busses = buses
    return departures
  }
  
  
  /**
   * Converts the bus json in to objects.
   */
  private static func convertBusesJson(json: JSON) -> [String: [RTBus]] {
    var result = [String: [RTBus]]()
    
    for busJson in json.array! {
      let rtBus = RTBus(
        stopAreaName: busJson["StopAreaName"].string!,
        lineNumber: busJson["LineNumber"].string!,
        destination: busJson["Destination"].string!,
        timeTabledDateTime: busJson["TimeTabledDateTime"].string!,
        expectedDateTime: busJson["ExpectedDateTime"].string!,
        displayTime: busJson["DisplayTime"].string!,
        deviations: [String](),
        journeyDirection: busJson["JourneyDirection"].int!,
        stopPointDesignation: busJson["StopPointDesignation"].string)
      
      if result["\(rtBus.stopAreaName)-\(rtBus.journeyDirection)"] == nil {
        result["\(rtBus.stopAreaName)-\(rtBus.journeyDirection)"] = [RTBus]()
      }
      result["\(rtBus.stopAreaName)-\(rtBus.journeyDirection)"]?.append(rtBus)
    }
    
    return result
  }
}
