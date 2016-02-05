//
//  RoutineService.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-24.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import CoreLocation

public class RoutineService {
  
  /**
   * Finds the all routine trip based on
   * current position, time and week day.
   */
  public static func findRoutineTrip(callback: ([RoutineTrip]) -> Void) {
    MyLocationHelper.sharedInstance.requestLocationUpdate { location in
      LocationSearchService.searchNearby(location, distance: 2000) { resTuple in
        if let error = resTuple.error {
          if error != SLNetworkError.NoDataFound {
            callback([RoutineTrip]())
          }
        }
        
        let allRoutineTrips = RoutineTripsStore.sharedInstance.retriveRoutineTrips()
        scoreRoutineTrips(allRoutineTrips, locations: resTuple.data)
        createPrioList(allRoutineTrips, callback: callback)
      }
    }
  }
  
  /**
   * Adds a habit routine (Smart suggestion).
   */
  public static func addHabitRoutine(crit: TripSearchCriterion) {
    let criterion = crit.copy() as! TripSearchCriterion
    criterion.resetAdvancedTripTypes()
    var routine = RoutineTripsStore.sharedInstance.retriveRoutineTripOnId(criterion.smartId())
    
    if routine == nil {
      routine = RoutineTrip(
        id: criterion.smartId(), title: "",
        criterions: criterion, isSmartSuggestion: true)
      RoutineTripsStore.sharedInstance.addRoutineTrip(routine!)
    } else {
      ScorePostHelper.changeScoreForRoutineTrip(
        routine!.criterions.origin!.siteId!,
        destinationId: routine!.criterions.dest!.siteId!,
        score: ScorePostHelper.OtherTapCountScore)
    }
  }
  
  // MARK: Private methods
  
  /**
  * Calcualtes and assinges search score
  * for the found routine trips.
  */
  private static func scoreRoutineTrips(routineTrips: [RoutineTrip], locations: [(location: Location, dist: Int)]) {
    let todayTimeTuple = createTimeTuple()
    
    for trip in routineTrips {
      print("")
      print("---------------------------------")
      print("\(trip.title!)")
      var multiplier = multiplierBasedOnProximityToLocation(trip, locations: locations)
      multiplier += multiplierBasedOnProximityToScorePostLocation(trip)
      trip.score = scoreBasedOnRoutineSchedule(trip, today: todayTimeTuple)
      multiplier = (multiplier == 0) ? 1 : multiplier
      trip.score = (trip.score < 2) ? multiplier * 2: trip.score * multiplier
      print("Multiplier: \(multiplier)")
      print("TOTAL: \(trip.score)")
      print("---------------------------------")
    }
  }
  
  /**
   * Creates a prioritized routine trip list.
   */
  private static func createPrioList(
    routineTrips: [RoutineTrip], callback: ([RoutineTrip]) -> Void) {
      let prioList = routineTrips.sort {$0.score > $1.score}
      let filteredList = filterSmartSuggestions(prioList)
      if filteredList.count > 0 {
        searchTripsForBestRoutine(filteredList[0]) { trips in
          if trips.count > 0 {
            filteredList[0].trips = trips
          }
          callback(filteredList)
          return
        }
        return
      }
      callback(filteredList)
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
    trip: RoutineTrip, locations: [(location: Location, dist: Int)]) -> Float {
      
      if trip.criterions.origin?.type == LocationType.Station {
        for location in locations {
          if trip.criterions.origin!.siteId == location.location.siteId {
            return calcMultiplierBasedOnProximityToLocation(location.dist)
          }
        }
      } else {
        if let currentLocation = MyLocationHelper.sharedInstance.currentLocation {
          let distance = Int(currentLocation.distanceFromLocation(trip.criterions.origin!.location))
          return calcMultiplierBasedOnProximityToLocation(distance)
        }
        
      }
      
      return 0.0
  }
  
  /**
   * Calculates score multiplier based on distance to location.
   */
  static private func calcMultiplierBasedOnProximityToLocation(distance: Int) -> Float {
    var tempMultiplier = Float(2000 - distance)
    tempMultiplier = (tempMultiplier > 0) ? tempMultiplier / 250.0 : 0.0
    print("Mult Based On Proximity To Location: \(tempMultiplier)")
    return tempMultiplier
  }
  
  /**
   * Score based on routine scheudle score.
   */
  static private func scoreBasedOnRoutineSchedule(
    trip: RoutineTrip, today: (dayInWeek: Int, hourOfDay: Int)) -> Float {
      
      let scorePosts = ScorePostStore.sharedInstance.retrieveScorePosts()
      var score = Float(0)
      for post in scorePosts {
        if checkMatch(post, trip: trip) {
          if post.dayInWeek == today.dayInWeek {
            score += (post.score * 0.2)
            if post.hourOfDay == today.hourOfDay {
              score += post.score
            }
          }
        }
      }
      print("Score Based On Schedule: \(min(score + 1, 20))")
      return min(score + 1, 20)
  }
  
  /**
   * Score based on current location proximity to locations logged with ScorePost.
   */
  static private func multiplierBasedOnProximityToScorePostLocation(trip: RoutineTrip) -> Float {
    var highestMulitplier = Float(0.0)
    if let currentLocation = MyLocationHelper.sharedInstance.currentLocation {
      let scorePosts = ScorePostStore.sharedInstance.retrieveScorePosts()
      for post in scorePosts {
        if checkMatch(post, trip: trip) {
          if let postLocation = post.location {
            let distance = postLocation.distanceFromLocation(currentLocation)
            var tempMultiplier = Float(800 - distance)
            tempMultiplier = (tempMultiplier > 0) ? tempMultiplier / 250.0 : 0.0
            highestMulitplier = (tempMultiplier > highestMulitplier) ? tempMultiplier : highestMulitplier
          }
        }
      }
    }
    print("Mult Based On Score Post: \(highestMulitplier)")
    return highestMulitplier
  }
  
  /**
   * Extracts an score post compative int tuple describing
   * time and date for RoutineTrip.
   */
  static private func createTimeTuple() -> (dayInWeek: Int, hourOfDay: Int) {
    return (DateUtils.getDayOfWeek(), DateUtils.getHourOfDay())
  }
  
  /**
   * Filters out smart suggestions from list.
   */
  static private func filterSmartSuggestions(routineTrips: [RoutineTrip]) -> [RoutineTrip] {
    var filteredList = [RoutineTrip]()
    for (index, routine) in routineTrips.enumerate() {
      if index == 0 && routine.isSmartSuggestion && routine.score > 25 && routineTrips.count > 1 {
        filteredList.append(routineTrips[0])
      } else if !routine.isSmartSuggestion {
        filteredList.append(routine)
      }
    }
    
    return filteredList
  }
  
  /**
   * Checks if score post is a match.
   */
  static private func checkMatch(post: ScorePost, trip: RoutineTrip) -> Bool {
    return (post.originId == trip.criterions.origin?.siteId &&
      post.destId == trip.criterions.dest?.siteId)
  }
}