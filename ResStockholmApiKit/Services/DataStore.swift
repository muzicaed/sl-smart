//
//  DataStore.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-22.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation

public class DataStore {
  
  private let defaults = NSUserDefaults.init(suiteName: "group.mikael-hellman.ResSmart")!
  private var cachedRoutineTrips = [RoutineTrip]()
  private var cachedScorePosts = [ScorePost]()
  private var cachedSearchCriterions: TripSearchCriterion?
  
  // Singelton pattern
  public static let sharedInstance = DataStore()
  
  /**
   * Preloads routine trip data.
   */
  public func preload() {
    cachedRoutineTrips = retrieveRoutineTripsFromStore()
    cachedScorePosts = retrieveScorePosts()
  }
  
  /**
   * Is empty
   */
  public func isRoutineTripsEmpty() -> Bool {
    return (cachedRoutineTrips.count == 0) ? true : false
  }
  
  /**
   * Adds a routine trip to data store
   */
  public func addRoutineTrip(trip: RoutineTrip) {
    trip.trips = [Trip]()
    cachedRoutineTrips = retrieveRoutineTripsFromStore()
    cachedRoutineTrips.append(trip)
    writeRoutineTripsToStore()
  }
  
  /**
   * Moves a routine trip in data store
   */
  public func moveRoutineTrip(index: Int, targetIndex: Int) {
    cachedRoutineTrips = retrieveRoutineTripsFromStore()
    let moveTrip = cachedRoutineTrips.removeAtIndex(index)
    cachedRoutineTrips.insert(moveTrip, atIndex: targetIndex)
    writeRoutineTripsToStore()
  }
  
  /**
   * Update a routine trip in data store
   */
  public func updateRoutineTrip(index: Int, trip: RoutineTrip) {
    trip.trips = [Trip]()
    cachedRoutineTrips[index] = trip
    writeRoutineTripsToStore()
  }
  
  /**
   * Delete a routine trip from data store
   */
  public func deleteRoutineTrip(index: Int) {
    cachedRoutineTrips.removeAtIndex(index)
    writeRoutineTripsToStore()
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
   * Retrive "ScoreList" from data store
   */
  public func retrieveScorePosts() -> [ScorePost] {
    if cachedScorePosts.count == 0 {
      if let unarchivedObject = defaults.objectForKey(PropertyKey.ScoreList) as? NSData {
        if let scorePosts = NSKeyedUnarchiver.unarchiveObjectWithData(unarchivedObject) as? [ScorePost] {
          cachedScorePosts = scorePosts
        }
      }
    }
    return cachedScorePosts.map { ($0.copy() as! ScorePost) }
  }
  
  /**
   * Store score lists to "ScoreList" in data store
   */
  public func writeScorePosts(scorePosts: [ScorePost]) {
    var filteredPosts = [ScorePost]()
    for post in scorePosts {
      if post.score > 0 {
        filteredPosts.append(post.copy() as! ScorePost)
      }
    }
    let archivedObject = NSKeyedArchiver.archivedDataWithRootObject(filteredPosts as NSArray)
    defaults.setObject(archivedObject, forKey: PropertyKey.ScoreList)
    cachedScorePosts = filteredPosts
    defaults.synchronize()
  }
  
  /**
   * Retrive "LastSearchCriterions" from data store
   */
  public func retrieveSearchCriterions() -> TripSearchCriterion {
    if cachedSearchCriterions == nil {
      
      if let unarchivedObject = defaults.objectForKey(
        PropertyKey.LastSearchCriterions) as? NSData {          
          if let crit = NSKeyedUnarchiver.unarchiveObjectWithData(unarchivedObject) as? TripSearchCriterion {
            cachedSearchCriterions = crit
            return cachedSearchCriterions!
          }
      }
    }
    return TripSearchCriterion(origin: nil, dest: nil)
  }
  
  /**
   * Store "LastSearchCriterions" in data store.
   */
  public func writeLastSearchCriterions(criterions: TripSearchCriterion) {
    let archivedObject = NSKeyedArchiver.archivedDataWithRootObject(criterions)
    defaults.setObject(archivedObject, forKey: PropertyKey.LastSearchCriterions)
    cachedSearchCriterions = criterions
    defaults.synchronize()
  }
  
  // MARK: Private
  
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
    let archivedObject = NSKeyedArchiver.archivedDataWithRootObject(cachedRoutineTrips as NSArray)
    defaults.setObject(archivedObject, forKey: PropertyKey.MyRoutineTrips)
    defaults.synchronize()
  }
  
  struct PropertyKey {
    static let MyRoutineTrips = "MyRoutineTrips"
    static let ScoreList = "ScoreList"
    static let LastSearchCriterions = "LastSearchCriterions"
  }
}