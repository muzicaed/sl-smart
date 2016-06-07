//
//  FavouriteLocationsStore.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-12-26.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation

public class FavouriteLocationsStore {
  
  private let FavouriteLocations = "FavouriteLocations"
  private let defaults = NSUserDefaults.init(suiteName: "group.mikael-hellman.ResSmart")!
  private var cachedLocations = [Location]()
  
  // Singelton pattern
  public static let sharedInstance = FavouriteLocationsStore()
  
  /**
   * Preloads favourite locations data.
   */
  public func preload() {
    cachedLocations = retrieveFavouriteLocations()
  }
  
  /**
   * Retrive "FavouriteLocations" from data store
   */
  public func retrieveFavouriteLocations() -> [Location] {
    if cachedLocations.count == 0 {
      
      if let unarchivedObject = defaults.objectForKey(FavouriteLocations) as? NSData {
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
  public func retrieveFavouriteStationsOnly() -> [Location] {
    cachedLocations = retrieveFavouriteLocations()
    return cachedLocations.filter() {
      if $0.type == LocationType.Station {
        return true
      }
      return false
    }
  }
  
  /**
   * Add a location to favourite location list.
   */
  public func addFavouriteLocation(location: Location) {
    cachedLocations = retrieveFavouriteLocations()
    cachedLocations = cachedLocations.filter() {
      if $0.siteId == location.siteId {
        return false
      }
      return true
    }
    cachedLocations.append(location)
    writeFavouriteLocations(cachedLocations)
  }
  
  /**
   * Remove a location from favourite location list.
   */
  public func removeFavouriteLocation(location: Location) {
    cachedLocations = retrieveFavouriteLocations()
    cachedLocations = cachedLocations.filter() {
      if $0.siteId == location.siteId {
        return false
      }
      return true
    }
    writeFavouriteLocations(cachedLocations)
  }
  
  /**
   * Check if location is a favourite.
   */
  public func isLocationFavourite(location: Location) -> Bool {
    let filteredLocations = cachedLocations.filter() {
      if $0.siteId == location.siteId {
        return true
      }
      return false
    }
    return (filteredLocations.count > 0)
  }
  
  /**
   * Moves a routine trip in data store
   */
  public func moveFavouriteLocation(index: Int, targetIndex: Int) {
    let moveLocation = cachedLocations.removeAtIndex(index)
    cachedLocations.insert(moveLocation, atIndex: targetIndex)
    writeFavouriteLocations(cachedLocations)
  }
  
  // MARK: Private
  
  /**
   * Store "FavouriteLocations" in data store.
   */
  private func writeFavouriteLocations(locations: [Location]) {
    let archivedObject = NSKeyedArchiver.archivedDataWithRootObject(locations)
    defaults.setObject(archivedObject, forKey: FavouriteLocations)
    cachedLocations = locations
  }
}