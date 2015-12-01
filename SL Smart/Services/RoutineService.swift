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
          print("---------------------------------")
          print("\(trip.title!)")
          var multiplier = multiplierBasedOnProximityToLocation(trip, locations: nearbyLocations)
          multiplier += multiplierBasedOnProximityToScorePostLocation(trip)
          trip.score = scoreBasedOnRoutineSchedule(trip, today: todayTimeTuple)
          trip.score = (trip.score == 0) ? multiplier * 5: trip.score * multiplier
          print("Multiplier: \(multiplier)")          
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
        var tempMultiplier = Float(1000 - location.dist)
        tempMultiplier = (tempMultiplier > 0) ? tempMultiplier / 250.0 : 0.0
        print("Prox to loc mult: \(tempMultiplier)")
        return tempMultiplier
      }
    }
    return 0.0
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
      print("Sched score: \(score)")
      return score
  }
  
  /**
   * Score based on current locatiosn proximity to locations logged with ScorePost.
   */
  static private func multiplierBasedOnProximityToScorePostLocation(trip: RoutineTrip) -> Float {
    var highestMulitplier = Float(0.0)
    if let currentLocation = MyLocationHelper.sharedInstance.currentLocation {
      let scorePosts = DataStore.sharedInstance.retrieveScorePosts()
      for post in scorePosts {
        if let postLocation = post.location {
          let distance = postLocation.distanceFromLocation(currentLocation)
          var tempMultiplier = Float(1000 - distance)
          tempMultiplier = (tempMultiplier > 0) ? tempMultiplier / 250.0 : 0.0
          highestMulitplier = (tempMultiplier > highestMulitplier) ? tempMultiplier : highestMulitplier
        }
      }
    }
    print("Prox to post mult: \(highestMulitplier)")
    return highestMulitplier
  }
  
  /**
   * Extracts an score post compative int tuple describing
   * time and date for RoutineTrip.
   */
  static private func createTimeTuple() -> (dayInWeek: Int, hourOfDay: Int) {
    return (Utils.getDayOfWeek(), Utils.getHourOfDay())
  }
}