//
//  LatestLocationsStore.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-12-26.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation

public class LatestLocationsStore {
  
  private let LatestLocations = "LatestLocations"
  private let defaults = NSUserDefaults.init(suiteName: "group.mikael-hellman.ResSmart")!
  private var cachedLocations = [Location]()
  
  // Singelton pattern
  public static let sharedInstance = LatestLocationsStore()
  
  /**
   * Preloads latest locations data.
   */
  public func preload() {
    cachedLocations = retrieveLatestLocations()
  }
  
  /**
   * Retrive "LatestLocations" from data store
   */
  public func retrieveLatestLocations() -> [Location] {
    if cachedLocations.count == 0 {
      
      if let unarchivedObject = defaults.objectForKey(
        LatestLocations) as? NSData {
          if let locations = NSKeyedUnarchiver.unarchiveObjectWithData(unarchivedObject) as? [Location] {
            cachedLocations = locations
            return cachedLocations
          }
      }
    }
    return cachedLocations
  }
  
  /**
   * Retrive "LatestLocations" filtered on stations from data store
   */
  public func retrieveLatestStationsOnly() -> [Location] {
    return cachedLocations.filter() {
      if $0.type == LocationType.Station {
        return true
      }
      return false
    }
  }
  
  /**
   * Add a location to latest location list.
   */
  public func addLatestLocation(location: Location) {
    cachedLocations = retrieveLatestLocations()
    cachedLocations = cachedLocations.filter() {
      if $0.siteId == location.siteId {
        return false
      }
      return true
    }
    
    cachedLocations.insert(location, atIndex: 0)
    if cachedLocations.count < 20 {
      writeLatestLocations(cachedLocations)
      return
    }
    
    writeLatestLocations(Array(cachedLocations[0...19]))
  }
  
  /**
   * Store "LatestLocations" in data store.
   */
  private func writeLatestLocations(locations: [Location]) {
    let archivedObject = NSKeyedArchiver.archivedDataWithRootObject(locations)
    defaults.setObject(archivedObject, forKey: LatestLocations)
    cachedLocations = locations
    defaults.synchronize()
  }
}