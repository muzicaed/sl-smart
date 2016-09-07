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
  
  private var cachedStops = [String: [StaticStop]]()
  private var cachedFlatStops = [String: StaticStop]()
  
  // Singelton pattern
  public static let sharedInstance = StopsStore()
  
  /**
   * Gets all static stops in a list grouped on StopAreaNumber.
   */
  public func getStops() -> [String: [StaticStop]] {
    if cachedStops.count == 0 {
      loadJson()
    }
    
    return cachedStops
  }
  
  /**
   * Gets static stop on id
   */
  public func getOnId(id: String) -> StaticStop {
    let stops = getFlatStops()
    if let stop = stops[id] {
      return stop
    }
    fatalError("Could not find stop with id: \(id)")
  }
  
  /**
   * Gets all static stops in a flat list.
   */
  public func getFlatStops() -> [String: StaticStop] {
    if cachedFlatStops.count == 0 {
      loadJson()
    }
    
    return cachedFlatStops
  }
  
  // MARK: Private
  
  /**
   * Loads static site data from json file.
   */
  private func loadJson() {
    let bundle = NSBundle.mainBundle()
    do {
      if let path = bundle.pathForResource("stop", ofType: "json") {
        let data = try NSData(contentsOfFile: path,options: .DataReadingMappedIfSafe)
        convertData(data)
      } else {
        print("Path not found for static sites.")
      }
    }
    catch {
      fatalError("Could not load site.json")
    }
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
          
          cachedFlatStops[stop.stopPointNumber] = stop
          if cachedStops[stop.stopAreaNumber] == nil {
            cachedStops[stop.stopAreaNumber] = [StaticStop]()
          }
          cachedStops[stop.stopAreaNumber]?.append(stop)
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