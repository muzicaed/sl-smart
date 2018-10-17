//
//  LatestLocationsStore.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-12-26.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation

open class LatestLocationsStore {
    
    fileprivate let LatestLocations = "LatestLocations"
    fileprivate let defaults = UserDefaults.init(suiteName: "group.mikael-hellman.ResSmart")!
    fileprivate var cachedLocations = [Location]()
    
    // Singelton pattern
    open static let sharedInstance = LatestLocationsStore()  
    
    /**
     * Retrive "LatestLocations" from data store
     */
    open func retrieveLatestLocations() -> [Location] {
        if cachedLocations.count == 0 {
            if let unarchivedObject = defaults.object(
                forKey: LatestLocations) as? Data {
                if let locations = NSKeyedUnarchiver.unarchiveObject(with: unarchivedObject) as? [Location] {
                    cachedLocations = locations
                }
            }
        }
        return cachedLocations.filter() {
            if FavouriteLocationsStore.sharedInstance.isLocationFavourite($0) {
                return false
            }
            return true
        }
    }
    
    /**
     * Retrive "LatestLocations" filtered on stations from data store
     */
    open func retrieveLatestStationsOnly() -> [Location] {
        cachedLocations = retrieveLatestLocations()
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
    open func addLatestLocation(_ location: Location) {
        cachedLocations = retrieveLatestLocations()
        cachedLocations = cachedLocations.filter() {
            if $0.siteId == location.siteId {
                return false
            }
            return true
        }
        
        cachedLocations.insert(location, at: 0)
        if cachedLocations.count < 20 {
            writeLatestLocations(cachedLocations)
            return
        }
        
        writeLatestLocations(Array(cachedLocations[0...19]))
    }
    
    /**
     * Store "LatestLocations" in data store.
     */
    fileprivate func writeLatestLocations(_ locations: [Location]) {
        let archivedObject = NSKeyedArchiver.archivedData(withRootObject: locations)
        defaults.set(archivedObject, forKey: LatestLocations)
        cachedLocations = locations
    }
}
