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
      api.getRealTimeTable(siteId) { (data, error) -> Void in
        if let d = data {
          if d.count == 0 {
            HttpRequestHelper.clearCache()
            callback(data: nil, error: SLNetworkError.noDataFound)            
            return
          }
          
          let jsonData = JSON(data: d)
          if jsonData["ResponseData"].isExists() {
            let result = convertJson(jsonData["ResponseData"])
            callback(data: result, error: error)
          }
          return
        }
        
        callback(data: nil, error: error)
      }
  }
  
  // MARK: Private
  
  /**
  * Converts the raw json string into array of Location.
  */
  fileprivate static func convertJson(_ json: JSON) -> RealTimeDepartures {
    let departures = RealTimeDepartures(
      lastUpdated: json["LatestUpdate"].string,
      dataAge: json["DataAge"].int!)
    
    departures.busses = convertBusesJson(json["Buses"])
    
    departures.metros = convertMetrosJson(json["Metros"])
    departures.trains = convertTrainsJson(json["Trains"])
    departures.trams = convertTramsJson(json["Trams"], isLocal: false)
    departures.localTrams = convertTramsJson(json["Trams"], isLocal: true)
    departures.boats = convertBoatsJson(json["Ships"])
    
    if json["StopPointDeviations"].array!.count > 0 {
      for messJson in json["StopPointDeviations"].array! {
        if let mess = messJson["Deviation"]["Text"].string {
          departures.deviations.append(mess)
        }
      }
    }
    return departures
  }
  
  
  /**
   * Converts the bus json in to objects.
   */
  fileprivate static func convertBusesJson(_ json: JSON) -> [String: [RTBus]] {
    var result = [String: [RTBus]]()
    
    for busJson in json.array! {
      let rtBus = RTBus(
        stopAreaName: busJson["StopAreaName"].string!,
        lineNumber: busJson["LineNumber"].string!,
        destination: busJson["Destination"].string!,
        displayTime: busJson["DisplayTime"].string!,
        deviations: extractDeviations(busJson["Deviations"].array),
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
  fileprivate static func convertMetrosJson(_ json: JSON) -> [String: [RTMetro]] {
    var result = [String: [RTMetro]]()
    
    for metroJson in json.array! {
      var messages = [String]()
      if let message = metroJson["PlatformMessage"].string {
        messages.append(message)
      }
      
      let rtMetro = RTMetro(
        stopAreaName: metroJson["StopAreaName"].string!,
        lineNumber: metroJson["LineNumber"].string!,
        destination: metroJson["Destination"].string!,
        displayTime: metroJson["DisplayTime"].string!,
        deviations: messages,
        journeyDirection: metroJson["JourneyDirection"].int!,
        platformMessage: metroJson["PlatformMessage"].string,
        metroLineId: metroJson["GroupOfLineId"].int!)
      
      if result["\(rtMetro.stopAreaName)-\(rtMetro.metroLineId)-\(rtMetro.journeyDirection)"] == nil {
        result["\(rtMetro.stopAreaName)-\(rtMetro.metroLineId)-\(rtMetro.journeyDirection)"] = [RTMetro]()
      }
      result["\(rtMetro.stopAreaName)-\(rtMetro.metroLineId)-\(rtMetro.journeyDirection)"]?.append(rtMetro)
    }
    
    return result
  }
  
  /**
   * Converts the train json in to objects.
   */
  fileprivate static func convertTrainsJson(_ json: JSON) -> [String: [RTTrain]] {
    var result = [String: [RTTrain]]()
    
    for trainJson in json.array! {
      let rtTrain = RTTrain(
        stopAreaName: trainJson["StopAreaName"].string!,
        lineNumber: trainJson["LineNumber"].string!,
        destination: trainJson["Destination"].string!,
        displayTime: trainJson["DisplayTime"].string!,
        deviations: extractDeviations(trainJson["Deviations"].array),
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
  fileprivate static func convertTramsJson(_ json: JSON, isLocal: Bool) -> [String: [RTTram]] {
    var result = [String: [RTTram]]()
    
    for tramJson in json.array! {
      let lineNo = Int(tramJson["LineNumber"].string!)!
      if (isLocal && lineNo > 23) || (!isLocal && lineNo < 23) {
        let rtTram = RTTram(
          stopAreaName: tramJson["StopAreaName"].string!,
          lineNumber: tramJson["LineNumber"].string!,
          destination: tramJson["Destination"].string!,
          displayTime: tramJson["DisplayTime"].string!,
          deviations: extractDeviations(tramJson["Deviations"].array),
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
  
  /**
   * Converts the tram json in to objects.
   */
  fileprivate static func convertBoatsJson(_ json: JSON) -> [String: [RTBoat]] {
    var result = [String: [RTBoat]]()
    
    for boatJson in json.array! {
      let rtBoat = RTBoat(
        stopAreaName: boatJson["StopAreaName"].string!,
        lineNumber: boatJson["LineNumber"].string!,
        destination: boatJson["Destination"].string!,
        displayTime: boatJson["DisplayTime"].string!,
        deviations: extractDeviations(boatJson["Deviations"].array),
        journeyDirection: boatJson["JourneyDirection"].int!,
        groupOfLine: boatJson["GroupOfLine"].string)
      
      if result["\(rtBoat.groupOfLine)-\(rtBoat.journeyDirection)"] == nil {
        result["\(rtBoat.groupOfLine)-\(rtBoat.journeyDirection)"] = [RTBoat]()
      }
      result["\(rtBoat.groupOfLine)-\(rtBoat.journeyDirection)"]?.append(rtBoat)
    }
    
    return result
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
