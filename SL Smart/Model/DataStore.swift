//
//  DataStore.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-22.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation

class DataStore {
  
  let defaults = NSUserDefaults.standardUserDefaults()
  var myRoutineTrips = [RoutineTrip]()
  
  // Singelton pattern
  static let sharedInstance = DataStore()
  
  /**
   * Adds a routine trip to data store
   */
  func addRoutineTrip(trip: RoutineTrip) {
    myRoutineTrips = retrieveRoutineTripsFromStore()
    myRoutineTrips.append(trip)
    writeRoutineTripsToStore()
  }
  
  /**
   * Moves a routine trip in data store
   */
  func moveRoutineTrip(index: Int, targetIndex: Int) {
    myRoutineTrips = retrieveRoutineTripsFromStore()
    let moveTrip = myRoutineTrips.removeAtIndex(index)
    myRoutineTrips.insert(moveTrip, atIndex: targetIndex)
    writeRoutineTripsToStore()
  }
  
  /**
   * Update a routine trip in data store
   */
  func updateRoutineTrip(index: Int, trip: RoutineTrip) {
    myRoutineTrips[index] = trip
    writeRoutineTripsToStore()
  }
  
  /**
   * Delete a routine trip from data store
   */
  func deleteRoutineTrip(index: Int) {
    myRoutineTrips.removeAtIndex(index)
    writeRoutineTripsToStore()
  }
  
  /**
   * Retrieves all routine trips from data store
   */
  func retriveRoutineTrips() -> [RoutineTrip] {
    if myRoutineTrips.count > 0  {
      return myRoutineTrips
    }
    
    myRoutineTrips = retrieveRoutineTripsFromStore()
    return myRoutineTrips
  }
  
  /**
   * Retrive "MyRoutineTrips" from data store
   */
  private func retrieveRoutineTripsFromStore() -> [RoutineTrip] {
    if let unarchivedObject = defaults.objectForKey(PropertyKey.MyRoutineTrips) as? NSData {
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
    let archivedObject = NSKeyedArchiver.archivedDataWithRootObject(myRoutineTrips as NSArray)
    defaults.setObject(archivedObject, forKey: PropertyKey.MyRoutineTrips)
    defaults.synchronize()
  }
  
  struct PropertyKey {
    static let MyRoutineTrips = "MyRoutineTrips"
  }
}