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
  
  private var cachedStops = [String: [String: StaticStop]]()
  
  // Singelton pattern
  public static let sharedInstance = StopsStore()
  
  /**
   * Gets all static stops.
   */
  public func getStops() -> [String: [String: StaticStop]] {
    if cachedStops.count == 0 {
      cachedStops = readJson()
    }
    
    return cachedStops
  }
  
  // MARK: Private
  
  /**
   * Reads static site data from json file.
   */
  private func readJson() -> [String: [String: StaticStop]] {
    let bundle = NSBundle.mainBundle()
    do {
      if let path = bundle.pathForResource("stop", ofType: "json") {
        let data = try NSData(contentsOfFile: path,options: .DataReadingMappedIfSafe)
        return convertData(data)
      } else {
        print("Path not found for static sites.")
      }
    }
    catch {
      fatalError("Could not load site.json")
    }
    
    
    return [String: [String: StaticStop]]()
  }
  
  /**
   * Converts json data to dictionary.
   */
  private func convertData(data: NSData) -> [String: [String: StaticStop]] {
    var results = [String: [String: StaticStop]]()
    let jsonData = JSON(data: data)
    print(jsonData)
    if jsonData["ResponseData"].isExists() {
      if let stopsJson = jsonData["ResponseData"]["Result"].array {
        for stop in stopsJson {
        }
      }
    }
    
    return results
  }
}