//
//  StopsStore.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-09-06.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation
import CoreLocation

public class StopsStore {
  
  private let StaticStopList = "StaticStopList"
  private let defaults = NSUserDefaults.init(suiteName: "group.mikael-hellman.ResSmart")!
  private var cachedStops = [String: StaticStop]()
  
  // Singelton pattern
  public static let sharedInstance = StopsStore()
  
  /**
   * Gets static stop on id
   */
  public func getOnId(id: String) -> StaticStop {
    let stops = getStops()
    if let stop = stops[convertId(id)] {
      return stop
    }
    fatalError("Could not find stop with id: \(id) = \(convertId(id))")
  }
  
  /**
   * Gets all static stops in a flat list.
   */
  public func getStops() -> [String: StaticStop] {
    if cachedStops.count == 0 {
      cachedStops = retrieveStaticStopsFromStore()
    }
    
    return cachedStops
  }
  
  /**
   * Loads static site data from json file.
   * Should only be triggred as part of migration.
   */
  public func loadJson() {
    let bundle = NSBundle.mainBundle()
    do {
      if let path = bundle.pathForResource("stop", ofType: "json") {
        let data = try NSData(contentsOfFile: path,options: .DataReadingMappedIfSafe)
        convertData(data)
        writeStaticStopsToStore()
      } else {
        print("Path not found for static sites.")
      }
    }
    catch {
      fatalError("Could not load site.json")
    }
  }
  
  // MARK: Private
  
  /**
   * Converts id to StopPointNumber
   */
  private func convertId(id: String) -> String {
    if id.characters.count > 5 {
      let sub = id.substringFromIndex(id.startIndex.advancedBy(4))
      let newId = String(Int(sub)!) // Remove leading zeros
      return newId
    }
    return id
  }
  
  /**
   * Converts json data to dictionary.
   */
  private func convertData(data: NSData) {
    let jsonData = JSON(data: data)
    if jsonData["ResponseData"].isExists() {
      if let stopsJson = jsonData["ResponseData"]["Result"].array {
        for stopJson in stopsJson {
          let stop = StaticStop(
            stopPointNumber: stopJson["StopPointNumber"].string!,
            stopPointName: stopJson["StopPointName"].string!,
            stopAreaNumber: stopJson["StopAreaNumber"].string!,
            location: createLocation(stopJson),
            type: createTripType(stopJson["StopAreaTypeCode"].string!))
          
          cachedStops[stop.stopPointNumber] = stop
        }
      }
    }
  }
  
  /**
   * Creates a CLLocation from Stop Json lat/long.
   */
  private func createLocation(stopJson: JSON) -> CLLocation {
    return CLLocation(
      latitude: Double(stopJson["LocationNorthingCoordinate"].string!)!,
      longitude: Double(stopJson["LocationEastingCoordinate"].string!)!)
  }
  
  /**
   * Retrive "StaticStopList" from data store
   */
  private func retrieveStaticStopsFromStore() -> [String: StaticStop] {
    if let unarchivedObject = defaults.objectForKey(StaticStopList) as? NSData {
      if let stops = NSKeyedUnarchiver.unarchiveObjectWithData(unarchivedObject) as? [String: StaticStop] {
        return stops
      }
      
    }
    return [String: StaticStop]()
  }
  
  /**
   * Store static stops lists to "StaticStopList" in data store
   */
  private func writeStaticStopsToStore() {
    let archivedObject = NSKeyedArchiver.archivedDataWithRootObject(cachedStops)
    defaults.setObject(archivedObject, forKey: StaticStopList)
  }
  
  /**
   * Creates trip type enum based on JSON StopAreaTypeCode
   */
  private func createTripType(typeCode: String) -> TripType {
    switch typeCode {
    case "BUSTERM":
      return TripType.Bus
    case "METROSTN":
      return TripType.Metro
    case "TRAMSTN":
      return TripType.Tram
    case "RAILWSTN":
      return TripType.Train
    case "SHIPBER":
      return TripType.Ship
    case "FERRYBER":
      return TripType.Ferry
    default:
      fatalError("Could not convert stop type code.")
    }
  }
}