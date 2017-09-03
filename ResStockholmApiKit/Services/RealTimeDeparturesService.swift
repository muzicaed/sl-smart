//
//  RealTimeDeparturesService.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-01-19.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation
import CoreLocation

open class RealTimeDeparturesService {
  
  fileprivate static let api = SLRealtimeDepartures()
  
  /**
   * Fetch geometry data
   */
  open static func fetch(_ siteId: Int,
                         callback: @escaping (_ data: RealTimeDepartures?, _ error: SLNetworkError?) -> Void) {
    api.getRealTimeTable(siteId) { (arg) -> Void in
      
      let (data, error) = arg
      if let d = data {
        if d.count == 0 {
          HttpRequestHelper.clearCache()
          callback(nil, SLNetworkError.noDataFound)
          return
        }
        
        let jsonData = JSON(data: d)
        let result = convertJson(jsonData["ResponseData"])
        callback(result, error)        
        return
      }
      
      callback(nil, error)
    }
  }
  
  // MARK: Private
  
  /**
   * Converts the raw json string into array of Location.
   */
  fileprivate static func convertJson(_ json: JSON) -> RealTimeDepartures {
    let departures = RealTimeDepartures(
      lastUpdated: json["LatestUpdate"].string,
      dataAge: json["DataAge"].int)
    
    departures.busses = convertBusesJson(json["Buses"])    
    departures.metros = convertMetrosJson(json["Metros"])
    departures.trains = convertTrainsJson(json["Trains"])
    departures.trams = convertTramsJson(json["Trams"], isLocal: false)
    departures.localTrams = convertTramsJson(json["Trams"], isLocal: true)
    departures.boats = convertBoatsJson(json["Ships"])
    
    if let arr = json["StopPointDeviations"].array {
      if arr.count > 0 {
        for messJson in arr {
          if let mess = messJson["Deviation"]["Text"].string, let type = messJson["StopInfo"]["TransportMode"].string {
            departures.deviations.append((type, mess))
          }
        }
      }
    }
    return departures
  }
  
  /**
   * Converts the bus json in to objects.
   */
  fileprivate static func convertBusesJson(_ json: JSON) -> [String: [RTTransport]] {
    var result = [String: [RTTransport]]()
    if let arr = json.array {
      for busJson in arr {
        let rtBus = createRTTransport(busJson)
        if result["\(rtBus.stopAreaName)"] == nil {
          result["\(rtBus.stopAreaName)"] = [RTTransport]()
        }
        result["\(rtBus.stopAreaName)"]?.append(rtBus)
      }
    }
    
    return result
  }
  
  /**
   * Converts the metro json in to objects.
   */
  fileprivate static func convertMetrosJson(_ json: JSON) -> [String: [RTTransport]] {
    var result = [String: [RTTransport]]()
    if let arr = json.array {
      for metroJson in arr {
        let rtMetro = createRTTransport(metroJson)
        let groupKey = "\(rtMetro.stopAreaName)-\(metroJson["GroupOfLine"].string!)-\(rtMetro.journeyDirection)"
        if result[groupKey] == nil {
          result[groupKey] = [RTTransport]()
        }
        result[groupKey]?.append(rtMetro)
      }
    }
    
    return result
  }
  
  /**
   * Converts the train json in to objects.
   */
  fileprivate static func convertTrainsJson(_ json: JSON) -> [String: [RTTransport]] {
    var result = [String: [RTTransport]]()
    if let arr = json.array {
      for trainJson in arr {
        let rtTrain = createRTTransport(trainJson)
        if result["\(rtTrain.stopAreaName)-\(rtTrain.journeyDirection)"] == nil {
          result["\(rtTrain.stopAreaName)-\(rtTrain.journeyDirection)"] = [RTTransport]()
        }
        result["\(rtTrain.stopAreaName)-\(rtTrain.journeyDirection)"]?.append(rtTrain)
      }
    }
    
    return result
  }
  
  /**
   * Converts the tram json in to objects.
   */
  fileprivate static func convertTramsJson(_ json: JSON, isLocal: Bool) -> [String: [RTTransport]] {
    var result = [String: [RTTransport]]()
    if let arr = json.array {
      for tramJson in arr {
        let lineNo = Int(tramJson["LineNumber"].string!)!
        if (isLocal && lineNo > 23) || (!isLocal && lineNo < 23) {
          let rtTram = createRTTransport(tramJson)
          if result["\(String(describing: rtTram.groupOfLine))-\(rtTram.journeyDirection)"] == nil {
            result["\(String(describing: rtTram.groupOfLine))-\(rtTram.journeyDirection)"] = [RTTransport]()
          }
          result["\(String(describing: rtTram.groupOfLine))-\(rtTram.journeyDirection)"]?.append(rtTram)
        }
      }
    }
    
    return result
  }
  
  /**
   * Converts the tram json in to objects.
   */
  fileprivate static func convertBoatsJson(_ json: JSON) -> [String: [RTTransport]] {
    var result = [String: [RTTransport]]()
    if let arr = json.array {
      for boatJson in arr {
        let rtBoat = createRTTransport(boatJson)
        if result["\(String(describing: rtBoat.groupOfLine))-\(rtBoat.journeyDirection)"] == nil {
          result["\(String(describing: rtBoat.groupOfLine))-\(rtBoat.journeyDirection)"] = [RTTransport]()
        }
        result["\(String(describing: rtBoat.groupOfLine))-\(rtBoat.journeyDirection)"]?.append(rtBoat)
      }
    }
    
    return result
  }
  
  fileprivate static func createRTTransport(_ json: JSON) -> RTTransport {
    return RTTransport(
      stopAreaName: json["StopAreaName"].string!,
      lineNumber: json["LineNumber"].string!,
      destination: json["Destination"].string!,
      displayTime: json["DisplayTime"].string!,
      deviations: extractDeviations(json["Deviations"].array),
      journeyDirection: json["JourneyDirection"].int!,
      stopPointDesignation: json["StopPointDesignation"].string,
      groupOfLine: json["GroupOfLine"].string,
      secondaryDestinationName: json["SecondaryDestinationName"].string)
  }
  
  /**
   * Extracts deviation messages.
   */
  fileprivate static func extractDeviations(_ messagesJson: [JSON]?) -> [String] {
    var result = [String]()
    if let messagesJson = messagesJson {
      for messJson in messagesJson {
        if let mess = messJson["Text"].string {
          result.append(mess)
        }
      }
    }
    return result
  }
}
