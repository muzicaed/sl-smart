//
//  RoutineService.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-24.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation

class RoutineService {
  
  /**
   * Finds the all routine trip based on
   * current position, time and week day.
   * TODO: Only test stub...
   */
  static func findRoutineTrip(callback: ([RoutineTrip]) -> Void) {
    MyLocationHelper.sharedInstance.requestLocationUpdate { location in
      StationSearchService.searchNearby(location) { nearbyLocations in
        let allRoutineTrips = DataStore.sharedInstance.retriveRoutineTrips()
        
        for trip in allRoutineTrips {
          trip.score = 0
          trip.score += RoutineService.scoreForLocation(trip, locations: nearbyLocations)
        }
        
        let prioList = allRoutineTrips.sort {$0.score > $1.score}
        if prioList.count > 10 {
          callback(Array(prioList[0..<10]) as [RoutineTrip])
          return
        }
        callback(prioList)
      }
    }
  }
  
  // MARK: Private methods
  
  /**
  * Score based on proximity to location.
  */
  static private func scoreForLocation(trip: RoutineTrip, locations: [(id: Int, dist: Int)]) -> Int {
    
    print("Trip id: \(trip.origin!.siteId)")
    
    for location in locations {
      if trip.origin!.siteId == location.id {
        if location.dist < 50 {
          return 20
        } else if location.dist > 50 && location.dist < 100 {
          return 10
        } else if location.dist > 10 && location.dist < 250 {
          return 8
        } else {
          return 5
        }
      }
    }
    return 0
  }
}