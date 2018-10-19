//
//  RoutineTripsStore.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-12-26.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation

open class RoutineTripsStore {
    
    fileprivate let MyRoutineTrips = "MyRoutineTrips"
    fileprivate let defaults = UserDefaults.init(suiteName: "group.mikael-hellman.ResSmart")!
    fileprivate var cachedRoutineTrips = [RoutineTrip]()
    
    // Singelton pattern
    public static let sharedInstance = RoutineTripsStore()
    
    /**
     * Preloads routine trip data.
     */
    public func preload() {
        cachedRoutineTrips = retrieveRoutineTripsFromStore()
    }
    
    /**
     * Is empty
     */
    public func isRoutineTripsEmpty() -> Bool {
        for trip in cachedRoutineTrips {
            if !trip.isSmartSuggestion {
                return false
            }
        }
        return true
    }
    
    /**
     * Adds a routine trip to data store
     */
    public func addRoutineTrip(_ trip: RoutineTrip) {
        trip.trips = [Trip]()
        cachedRoutineTrips = retrieveRoutineTripsFromStore()
        cachedRoutineTrips.append(trip)
        writeRoutineTripsToStore()
    }
    
    /**
     * Moves a routine trip in data store
     */
    public func moveRoutineTrip(_ index: Int, targetIndex: Int) {
        let moveTrip = cachedRoutineTrips.remove(at: index)
        cachedRoutineTrips.insert(moveTrip, at: targetIndex)
        writeRoutineTripsToStore()
    }
    
    /**
     * Update a routine trip in data store
     */
    public func updateRoutineTrip(_ trip: RoutineTrip) {
        trip.trips = [Trip]()
        for (index, testRoutine) in cachedRoutineTrips.enumerated() {
            if testRoutine.id == trip.id {
                cachedRoutineTrips[index] = trip.copy() as! RoutineTrip
                writeRoutineTripsToStore()
                return
            }
        }
    }
    
    /**
     * Delete a routine trip from data store
     */
    public func deleteRoutineTrip(_ id: String) {
        cachedRoutineTrips = retrieveRoutineTripsFromStore()
        for (index, routine) in cachedRoutineTrips.enumerated() {
            if routine.id == id {
                cachedRoutineTrips.remove(at: index)
                writeRoutineTripsToStore()
                return
            }
        }
    }
    
    /**
     * Retrieve a routine trip from data store for a id
     */
    public func retriveRoutineTripOnId(_ id: String) -> RoutineTrip? {
        let trips = retriveRoutineTrips()
        if let index = trips.index(where: {$0.id == id}) {
            return trips[index].copy() as? RoutineTrip
        }
        return nil
    }
    
    /**
     * Retrieves all routine trips from data store
     */
    public func retriveRoutineTrips() -> [RoutineTrip] {
        if cachedRoutineTrips.count == 0  {
            cachedRoutineTrips = retrieveRoutineTripsFromStore()
        }
        
        return cachedRoutineTrips.map { ($0.copy() as! RoutineTrip) }
    }
    
    /**
     * Retrieves all routine trips except for "Smart suggestions" from data store
     */
    public func retriveRoutineTripsNoSuggestions() -> [RoutineTrip] {
        if cachedRoutineTrips.count == 0  {
            cachedRoutineTrips = retrieveRoutineTripsFromStore()
        }
        
        let filtered = cachedRoutineTrips.filter{ !$0.isSmartSuggestion }
        return filtered.map { ($0.copy() as! RoutineTrip) }
    }
    
    // MARK: Private
    
    /**
     * Retrive "MyRoutineTrips" from data store
     */
    fileprivate func retrieveRoutineTripsFromStore() -> [RoutineTrip] {
        if let unarchivedObject = defaults.object(forKey: MyRoutineTrips) as? Data {
            if let trips = NSKeyedUnarchiver.unarchiveObject(with: unarchivedObject) as? [RoutineTrip] {
                return trips
            }
            
        }
        return [RoutineTrip]()
    }
    
    /**
     * Store routine trip to "MyRoutineTrips" in data store
     */
    fileprivate func writeRoutineTripsToStore() {
        let archivedObject = NSKeyedArchiver.archivedData(withRootObject: cachedRoutineTrips as NSArray)
        defaults.set(archivedObject, forKey: MyRoutineTrips)
        cachedRoutineTrips = retrieveRoutineTripsFromStore()
    }
}
