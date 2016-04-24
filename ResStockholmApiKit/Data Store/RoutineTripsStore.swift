//
//  RoutineTripsStore.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-12-26.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation

public class RoutineTripsStore {
  
  private let MyRoutineTrips = "MyRoutineTrips"
  private let defaults = NSUserDefaults.init(suiteName: "group.mikael-hellman.ResSmart")!
  private var cachedRoutineTrips = [RoutineTrip]()
  
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
  public func addRoutineTrip(trip: RoutineTrip) {
    cleanOutMatchingHabitRoutines(trip)
    trip.trips = [Trip]()
    cachedRoutineTrips = retrieveRoutineTripsFromStore()
    cachedRoutineTrips.append(trip)
    writeRoutineTripsToStore()
  }
  
  /**
   * Moves a routine trip in data store
   */
  public func moveRoutineTrip(index: Int, targetIndex: Int) {
    let moveTrip = cachedRoutineTrips.removeAtIndex(index)
    cachedRoutineTrips.insert(moveTrip, atIndex: targetIndex)
    writeRoutineTripsToStore()
  }
  
  /**
   * Update a routine trip in data store
   */
  public func updateRoutineTrip(trip: RoutineTrip) {
    trip.trips = [Trip]()
    for (index, testRoutine) in cachedRoutineTrips.enumerate() {
      if testRoutine.id == trip.id {
        cachedRoutineTrips[index] = trip.copy() as! RoutineTrip
        writeRoutineTripsToStore()
        cleanOutMatchingHabitRoutines(trip)
        return
      }
    }
  }
  
  /**
   * Delete a routine trip from data store
   */
  public func deleteRoutineTrip(id: String) {
    cachedRoutineTrips = retrieveRoutineTripsFromStore()
    for (index, routine) in cachedRoutineTrips.enumerate() {
      if routine.id == id {
        cachedRoutineTrips.removeAtIndex(index)
        writeRoutineTripsToStore()
        return
      }
    }
  }
  
  /**
   * Retrieve a routine trip from data store for a id
   */
  public func retriveRoutineTripOnId(id: String) -> RoutineTrip? {
    let trips = retriveRoutineTrips()
    if let index = trips.indexOf({$0.id == id}) {
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
  private func retrieveRoutineTripsFromStore() -> [RoutineTrip] {
    if let unarchivedObject = defaults.objectForKey(MyRoutineTrips) as? NSData {
      if let trips = NSKeyedUnarchiver.unarchiveObjectWithData(unarchivedObject) as? [RoutineTrip] {
        return trips
      }
      
    }
    return [RoutineTrip]()
  }
  
  /**
   * Store routine trip to "MyRoutineTrips" in data store
   */
  private func writeRoutineTripsToStore() {
    let archivedObject = NSKeyedArchiver.archivedDataWithRootObject(cachedRoutineTrips as NSArray)
    defaults.setObject(archivedObject, forKey: MyRoutineTrips)
    cachedRoutineTrips = retrieveRoutineTripsFromStore()
  }
  
  /**
   * Delete mathing habit routines (Smart suggestions)
   */
  private func cleanOutMatchingHabitRoutines(trip: RoutineTrip) {
    for testRoutine in cachedRoutineTrips {
      if testRoutine.isSmartSuggestion {
        if trip.criterions.originId == testRoutine.criterions.originId &&
          trip.criterions.dest?.siteId == testRoutine.criterions.dest?.siteId {
            deleteRoutineTrip(testRoutine.id)
        }
      }
    }
  }
}