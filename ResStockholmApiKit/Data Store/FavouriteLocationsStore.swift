//
//  FavouriteLocationsStore.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-12-26.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation

open class FavouriteLocationsStore {
  
  fileprivate let FavouriteLocations = "FavouriteLocations"
  fileprivate let defaults = UserDefaults.init(suiteName: "group.mikael-hellman.ResSmart")!
  fileprivate var cachedLocations = [Location]()
  
  // Singelton pattern
  open static let sharedInstance = FavouriteLocationsStore()  
  
  /**
   * Retrive "FavouriteLocations" from data store
   */
  open func retrieveFavouriteLocations() -> [Location] {
    if cachedLocations.count == 0 {
      
      if let unarchivedObject = defaults.object(forKey: FavouriteLocations) as? Data {
        if let locations = NSKeyedUnarchiver.unarchiveObject(with: unarchivedObject) as? [Location] {
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
  open func retrieveFavouriteStationsOnly() -> [Location] {
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
  open func addFavouriteLocation(_ location: Location) {
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
  open func removeFavouriteLocation(_ location: Location) {
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
  open func isLocationFavourite(_ location: Location) -> Bool {
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
  open func moveFavouriteLocation(_ index: Int, targetIndex: Int) {
    let moveLocation = cachedLocations.remove(at: index)
    cachedLocations.insert(moveLocation, at: targetIndex)
    writeFavouriteLocations(cachedLocations)
  }
  
  // MARK: Private
  
  /**
   * Store "FavouriteLocations" in data store.
   */
  fileprivate func writeFavouriteLocations(_ locations: [Location]) {
    let archivedObject = NSKeyedArchiver.archivedData(withRootObject: locations)
    defaults.set(archivedObject, forKey: FavouriteLocations)
    cachedLocations = locations
  }
}
