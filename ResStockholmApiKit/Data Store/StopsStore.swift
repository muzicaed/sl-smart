//
//  StopsStore.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-09-06.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation
import CoreLocation

open class StopsStore {
  
  fileprivate let StaticStopList = "StaticStopList"
  fileprivate let defaults = UserDefaults.init(suiteName: "group.mikael-hellman.ResSmart")!
  fileprivate var cachedStops = [String: StaticStop]()
  
  // Singelton pattern
  open static let sharedInstance = StopsStore()
  
  /**
   * Gets static stop on id
   */
  open func getOnId(_ id: String) -> StaticStop? {
    let stops = getStops()
    if let stop = stops[convertId(id)] {
      return stop
    }
    print("Could not find stop with id: \(id) = \(convertId(id))")
    return nil
  }
  
  /**
   * Gets all static stops in a flat list.
   */
  open func getStops() -> [String: StaticStop] {
    if cachedStops.count == 0 {
      cachedStops = retrieveStaticStopsFromStore()
    }
    
    return cachedStops
  }
  
  /**
   * Loads static site data from json file.
   * Should only be triggred as part of migration.
   */
  open func loadJson() {
    let bundle = Bundle.main
    do {
      if let path = bundle.path(forResource: "stop", ofType: "json") {
        let data = try Data(contentsOf: URL(fileURLWithPath: path),options: .mappedIfSafe)
        convertData(data)
        writeStaticStopsToStore()
      } else {
        fatalError("Path not found for static sites.")
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
  fileprivate func convertId(_ id: String) -> String {
    if id.characters.count > 5 {
      let index = id.index(id.startIndex, offsetBy: 4)
      let sub = id[index..<id.endIndex]
      let newId = String(Int(sub)!) // Remove leading zeros
      return newId
    }
    return id
  }
  
  /**
   * Converts json data to dictionary.
   */
  fileprivate func convertData(_ data: Data) {
    let jsonData = JSON(data: data)    
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
  
  /**
   * Creates a CLLocation from Stop Json lat/long.
   */
  fileprivate func createLocation(_ stopJson: JSON) -> CLLocation {
    return CLLocation(
      latitude: Double(stopJson["LocationNorthingCoordinate"].string!)!,
      longitude: Double(stopJson["LocationEastingCoordinate"].string!)!)
  }
  
  /**
   * Retrive "StaticStopList" from data store
   */
  fileprivate func retrieveStaticStopsFromStore() -> [String: StaticStop] {
    if let unarchivedObject = defaults.object(forKey: StaticStopList) as? Data {
      if let stops = NSKeyedUnarchiver.unarchiveObject(with: unarchivedObject) as? [String: StaticStop] {
        return stops
      }
      
    }
    return [String: StaticStop]()
  }
  
  /**
   * Store static stops lists to "StaticStopList" in data store
   */
  fileprivate func writeStaticStopsToStore() {
    let archivedObject = NSKeyedArchiver.archivedData(withRootObject: cachedStops)
    defaults.set(archivedObject, forKey: StaticStopList)
  }
  
  /**
   * Creates trip type enum based on JSON StopAreaTypeCode
   */
  fileprivate func createTripType(_ typeCode: String) -> TripType {
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
