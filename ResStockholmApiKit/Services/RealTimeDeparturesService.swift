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
    let departures = RealTimeDepartures(
      lastUpdated: json["LatestUpdate"].string!,
      dataAge: json["DataAge"].int!)
    
    departures.busses = convertBusesJson(json["Buses"])
    departures.greenMetros = convertMetrosJson(json["Metros"], lineId: 1)
    departures.redMetros = convertMetrosJson(json["Metros"], lineId: 2)
    departures.blueMetros = convertMetrosJson(json["Metros"], lineId: 3)
    departures.trains = convertTrainsJson(json["Trains"])
    departures.trams = convertTramsJson(json["Trams"], isLocal: false)
    departures.localTrams = convertTramsJson(json["Trams"], isLocal: true)
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
        displayTime: busJson["DisplayTime"].string!,
        deviations: [String](),
        journeyDirection: busJson["JourneyDirection"].int!,
        stopPointDesignation: busJson["StopPointDesignation"].string)
      
      if result["\(rtBus.stopAreaName)"] == nil {
        result["\(rtBus.stopAreaName)"] = [RTBus]()
      }
      result["\(rtBus.stopAreaName)"]?.append(rtBus)
    }
    
    return result
  }
  
  /**
   * Converts the metro json in to objects.
   */
  private static func convertMetrosJson(json: JSON, lineId: Int) -> [String: [RTMetro]] {
    var result = [String: [RTMetro]]()
    
    for metroJson in json.array! {
      if metroJson["GroupOfLineId"].int! == lineId {
        let rtMetro = RTMetro(
          stopAreaName: metroJson["StopAreaName"].string!,
          lineNumber: metroJson["LineNumber"].string!,
          destination: metroJson["Destination"].string!,
          displayTime: metroJson["DisplayTime"].string!,
          deviations: [String](),
          journeyDirection: metroJson["JourneyDirection"].int!,
          platformMessage: metroJson["PlatformMessage"].string)
        
        if result["\(rtMetro.stopAreaName)-\(rtMetro.journeyDirection)"] == nil {
          result["\(rtMetro.stopAreaName)-\(rtMetro.journeyDirection)"] = [RTMetro]()
        }
        result["\(rtMetro.stopAreaName)-\(rtMetro.journeyDirection)"]?.append(rtMetro)
      }
    }
    
    return result
  }
  
  /**
   * Converts the train json in to objects.
   */
  private static func convertTrainsJson(json: JSON) -> [String: [RTTrain]] {
    var result = [String: [RTTrain]]()
    
    for trainJson in json.array! {
      let rtTrain = RTTrain(
        stopAreaName: trainJson["StopAreaName"].string!,
        lineNumber: trainJson["LineNumber"].string!,
        destination: trainJson["Destination"].string!,
        displayTime: trainJson["DisplayTime"].string!,
        deviations: [String](),
        journeyDirection: trainJson["JourneyDirection"].int!,
        secondaryDestinationName: trainJson["SecondaryDestinationName"].string)
      
      if result["\(rtTrain.stopAreaName)-\(rtTrain.journeyDirection)"] == nil {
        result["\(rtTrain.stopAreaName)-\(rtTrain.journeyDirection)"] = [RTTrain]()
      }
      result["\(rtTrain.stopAreaName)-\(rtTrain.journeyDirection)"]?.append(rtTrain)
    }
    
    return result
  }
  
  /**
   * Converts the tram json in to objects.
   */
  private static func convertTramsJson(json: JSON, isLocal: Bool) -> [String: [RTTram]] {
    var result = [String: [RTTram]]()
    
    for tramJson in json.array! {
      let lineNo = Int(tramJson["LineNumber"].string!)!
      if (isLocal && lineNo > 23) || (!isLocal && lineNo < 23) {
        let rtTram = RTTram(
          stopAreaName: tramJson["StopAreaName"].string!,
          lineNumber: tramJson["LineNumber"].string!,
          destination: tramJson["Destination"].string!,
          displayTime: tramJson["DisplayTime"].string!,
          deviations: [String](),
          journeyDirection: tramJson["JourneyDirection"].int!,
          stopPointDesignation: tramJson["StopPointDesignation"].string,
          groupOfLine: tramJson["GroupOfLine"].string!)
        
        if result["\(rtTram.groupOfLine)-\(rtTram.journeyDirection)"] == nil {
          result["\(rtTram.groupOfLine)-\(rtTram.journeyDirection)"] = [RTTram]()
        }
        result["\(rtTram.groupOfLine)-\(rtTram.journeyDirection)"]?.append(rtTram)
      }
    }
    
    return result
  }
}
