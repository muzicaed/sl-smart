//
//  RoutineService.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-24.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation

public class RoutineService {
  
  /**
   * Finds the all routine trip based on
   * current position, time and week day.
   */
  public static func findRoutineTrip(callback: ([RoutineTrip]) -> Void) {
    MyLocationHelper.sharedInstance.requestLocationUpdate { location in
      LocationSearchService.searchNearby(location) { resTuple in        
        if let error = resTuple.error {
          if error != SLNetworkError.NoDataFound {
            callback([RoutineTrip]())
          }
        }
        
        let allRoutineTrips = RoutineTripsStore.sharedInstance.retriveRoutineTrips()
        scoreRoutineTrips(allRoutineTrips, lcations: resTuple.data)
        createPrioList(allRoutineTrips, callback: callback)
      }
    }
  }
  
  // MARK: Private methods
  
  /**
  * Calcualtes and assinges search score
  * for the found routine trips.
  */
  private static func scoreRoutineTrips(routineTrips: [RoutineTrip], lcations: [(id: Int, dist: Int)]) {
    let todayTimeTuple = createTimeTuple()
    
    for trip in routineTrips {
      print("---------------------------------")
      print("\(trip.title!)")
      var multiplier = multiplierBasedOnProximityToLocation(trip, locations: lcations)
      multiplier += multiplierBasedOnProximityToScorePostLocation(trip)
      trip.score = scoreBasedOnRoutineSchedule(trip, today: todayTimeTuple)
      trip.score = (trip.score == 0) ? multiplier * 5: trip.score * multiplier
      print("Multiplier: \(multiplier)")
      print("TOTAL: \(trip.score)")
    }
  }
  
  /**
   * Creates a prioritized routine trip list.
   */
  private static func createPrioList(
    routineTrips: [RoutineTrip], callback: ([RoutineTrip]) -> Void) {
      let prioList = routineTrips.sort {$0.score > $1.score}
      if prioList.count > 10 {
        callback(Array(prioList[0..<10]) as [RoutineTrip])
        return
      }
      if prioList.count > 0 {
        searchTripsForBestRoutine(prioList[0]) { trips in
          if trips.count > 0 {
            prioList[0].trips = trips
          }
          callback(prioList)
        }
        return
      }
      callback(prioList)
  }
  
  /**
   * Searches trips data for best RoutineTrip
   */
  static private func searchTripsForBestRoutine(
    bestRoutineTrip: RoutineTrip?, callback: ([Trip]) -> Void) {
      if let routineTrip = bestRoutineTrip {
        
        if let searchCrit = routineTrip.criterions.copy() as? TripSearchCriterion {
          searchCrit.date = DateUtils.dateAsDateString(NSDate())
          searchCrit.time = DateUtils.dateAsTimeString(NSDate())
          searchCrit.numTrips = 1
          
          SearchTripService.tripSearch(searchCrit, callback: { resTuple in
            if let _ = resTuple.error {
              callback([Trip]())
            }
            callback(resTuple.data)
          })
          return
        }
      }
      callback([Trip]())
  }
  
  /**
   * Score multiplier based on proximity to location.
   */
  static private func multiplierBasedOnProximityToLocation(
    trip: RoutineTrip, locations: [(id: Int, dist: Int)]) -> Float {
      for location in locations {
        if trip.criterions.origin!.siteId == location.id {
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
      
      let scorePosts = ScorePostStore.sharedInstance.retrieveScorePosts()
      var score = Float(0)
      for post in scorePosts {
        if post.isOrigin && post.siteId == trip.criterions.origin!.siteId ||
          !post.isOrigin && post.siteId == trip.criterions.dest!.siteId {
            
            if post.dayInWeek == today.dayInWeek {
              score += (post.score * 0.3)
              if post.hourOfDay == today.hourOfDay {
                score += (post.isOrigin) ? (post.score * 0.7) : (post.score)
              }
            }
        }
      }
      print("Schedule score: \(score)")
      return score
  }
  
  /**
   * Score based on current location proximity to locations logged with ScorePost.
   */
  static private func multiplierBasedOnProximityToScorePostLocation(trip: RoutineTrip) -> Float {
    var highestMulitplier = Float(0.0)
    if let currentLocation = MyLocationHelper.sharedInstance.currentLocation {
      let scorePosts = ScorePostStore.sharedInstance.retrieveScorePosts()
      for post in scorePosts {
        if let postLocation = post.location {
          let distance = postLocation.distanceFromLocation(currentLocation)
          var tempMultiplier = Float(1000 - distance)
          tempMultiplier = (tempMultiplier > 0) ? tempMultiplier / 250.0 : 0.0
          highestMulitplier = (tempMultiplier > highestMulitplier) ? tempMultiplier : highestMulitplier
        }
      }
    }
    print("Prox to post pos mult: \(highestMulitplier)")
    return highestMulitplier
  }
  
  /**
   * Extracts an score post compative int tuple describing
   * time and date for RoutineTrip.
   */
  static private func createTimeTuple() -> (dayInWeek: Int, hourOfDay: Int) {
    return (DateUtils.getDayOfWeek(), DateUtils.getHourOfDay())
  }
}