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
        let todayTimeTuple = createTimeTuple()
        
        for trip in allRoutineTrips {
          let multiplier = multiplierBasedOnProximityToLocation(trip, locations: nearbyLocations)
          print("---------------------------------")
          print("\(trip.title!)")
          trip.score = Float(0.0)
          trip.score = scoreBasedOnRoutineSchedule(trip, today: todayTimeTuple)
          print("Schedule: \(trip.score)")
          print("Multiplier: \(multiplier)")
          trip.score = (trip.score == 0) ? multiplier * 5: trip.score * multiplier
          print("TOTAL: \(trip.score)")
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
  * Score multiplier based on proximity to location.
  */
  static private func multiplierBasedOnProximityToLocation(trip: RoutineTrip, locations: [(id: Int, dist: Int)]) -> Float {
    for location in locations {
      if trip.origin!.siteId == location.id {
        if location.dist <= 50 {
          return 5
        } else if location.dist > 50 && location.dist <= 100 {
          return 3
        } else if location.dist > 100 && location.dist <= 250 {
          return 1.8
        } else if location.dist > 500 && location.dist <= 1000 {
          return 1.6
        } else if location.dist > 1000 && location.dist <= 1500 {
          return 1.4
        } else {
          return 1.2
        }
      }
    }
    return 0
  }
  
  
  /**
   * Score based on routine scheudle score.
   */
  static private func scoreBasedOnRoutineSchedule(
    trip: RoutineTrip, today: (dayInWeek: Int, hourOfDay: Int)) -> Float {
      
      let scorePosts = DataStore.sharedInstance.retrieveScorePosts()
      var score = Float(0)
      for post in scorePosts {
        if post.isOrigin && post.siteId == trip.origin!.siteId ||
          !post.isOrigin && post.siteId == trip.destination!.siteId {
            
            if post.dayInWeek == today.dayInWeek {
              score += (post.score * 0.3)
              if post.hourOfDay == today.hourOfDay {
                score += (post.isOrigin) ? (post.score * 0.7) : (post.score)
              }
            }
        }
      }
      return score
  }
  
  /**
   * Extracts an score post compative int tuple describing
   * time and date for RoutineTrip.
   */
  static private func createTimeTuple() -> (dayInWeek: Int, hourOfDay: Int) {
    return (Utils.getDayOfWeek(), Utils.getHourOfDay())
  }
}