//
//  RoutineService.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-24.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import CoreLocation

open class RoutineService {
  
  /**
   * Finds the all routine trip based on
   * current position, time and week day.
   */
  open static func findRoutineTrip(_ callback: @escaping ([RoutineTrip]) -> Void) {
    MyLocationHelper.sharedInstance.requestLocationUpdate { location in
      LocationSearchService.searchNearby(location, distance: 2000) { resTuple in
        if let error = resTuple.1 {
          if error != SLNetworkError.noDataFound {
            callback([RoutineTrip]())
          }
        }
        
        let allRoutineTrips = RoutineTripsStore.sharedInstance.retriveRoutineTrips()
        scoreRoutineTrips(allRoutineTrips, locations: resTuple.0)
        createPrioList(allRoutineTrips, callback: callback)
      }
    }
  }
  
  /**
   * Adds a habit routine (Smart suggestion).
   */
  open static func addHabitRoutine(_ crit: TripSearchCriterion) {
    let criterion = crit.copy() as! TripSearchCriterion
    criterion.resetAdvancedTripTypes()
    criterion.date = nil
    criterion.time = nil
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
  fileprivate static func scoreRoutineTrips(_ routineTrips: [RoutineTrip], locations: [(location: Location, dist: Int)]) {
    let todayTimeTuple = createTimeTuple()
    
    for trip in routineTrips {
      var multiplier = multiplierBasedOnProximityToLocation(trip, locations: locations)
      multiplier += multiplierBasedOnProximityToScorePostLocation(trip)
      multiplier += multiplierBasedOnArrivalTime(trip)
      trip.score = scoreBasedOnRoutineSchedule(trip, today: todayTimeTuple)
      multiplier = (multiplier == 0) ? 1 : multiplier
      trip.score = (trip.score < 2) ? multiplier * 2: trip.score * multiplier
    }
  }
  
  /**
   * Creates a prioritized routine trip list.
   */
  fileprivate static func createPrioList(
    _ routineTrips: [RoutineTrip], callback: @escaping ([RoutineTrip]) -> Void) {
    let prioList = routineTrips.sorted {$0.score > $1.score}
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
  static fileprivate func searchTripsForBestRoutine(
    _ bestRoutineTrip: RoutineTrip?, callback: @escaping ([Trip]) -> Void) {
    if let routineTrip = bestRoutineTrip {
      
      if let searchCrit = routineTrip.criterions.copy() as? TripSearchCriterion {
        if searchCrit.time != nil {
          searchCrit.searchForArrival = true
          searchCrit.numTrips = 1        
        }
        let timeDateTuple = createDateTimeTuple(routineTrip.criterions)
        searchCrit.date = timeDateTuple.date
        searchCrit.time = timeDateTuple.time
        
        
        SearchTripService.tripSearch(searchCrit, callback: { resTuple in
          if let _ = resTuple.1 {
            callback([Trip]())
          }
          callback(resTuple.0)
        })
        return
      }
    }
    callback([Trip]())
  }
  
  /**
   * Create date & time tuple.
   * Takes routine arrival time in to consideration.
   */
  static fileprivate func createDateTimeTuple(_ criterions: TripSearchCriterion) -> (date: String, time: String) {
    if let time = criterions.time {
      let now = Date()
      let date = DateUtils.convertDateString("\(DateUtils.dateAsDateString(now)) \(time)")
      if date.timeIntervalSinceNow > (60 * 60) * -1 {
        return (DateUtils.dateAsDateString(now), time)
      } else {
        let tomorrow = now.addingTimeInterval(60 * 60 * 24 * 1)
        return (DateUtils.dateAsDateString(tomorrow), time)
      }
    }
    
    return (DateUtils.dateAsDateString(Date()), DateUtils.dateAsTimeString(Date()))
  }
  
  /**
   * Score multiplier based on proximity to location.
   */
  static fileprivate func multiplierBasedOnProximityToLocation(_ trip: RoutineTrip,
                                                           locations: [(location: Location, dist: Int)]) -> Float {
    
    if trip.criterions.origin?.type == LocationType.Station {
      for location in locations {
        if trip.criterions.origin!.siteId == location.location.siteId {
          return calcMultiplierBasedOnProximityToLocation(location.dist)
        }
      }
    } else {
      if let currentLocation = MyLocationHelper.sharedInstance.currentLocation {
        let distance = Int(currentLocation.distance(from: trip.criterions.origin!.location))
        return calcMultiplierBasedOnProximityToLocation(distance)
      }
      
    }
    
    return 0.0
  }
  
  /**
   * Calculates score multiplier based on distance to location.
   */
  static fileprivate func calcMultiplierBasedOnProximityToLocation(_ distance: Int) -> Float {
    var tempMultiplier = Float(2000 - distance)
    tempMultiplier = (tempMultiplier > 0) ? tempMultiplier / 250.0 : 0.0
    return tempMultiplier
  }
  
  /**
   * Score based on routine scheudle score.
   */
  static fileprivate func scoreBasedOnRoutineSchedule(
    _ trip: RoutineTrip, today: (dayInWeek: Int, hourOfDay: Int)) -> Float {
    
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
    return min(score + 1, 20)
  }
  
  /**
   * Score based on current location proximity to locations logged with ScorePost.
   */
  static fileprivate func multiplierBasedOnProximityToScorePostLocation(_ trip: RoutineTrip) -> Float {
    var highestMulitplier = Float(0.0)
    if let currentLocation = MyLocationHelper.sharedInstance.currentLocation {
      let scorePosts = ScorePostStore.sharedInstance.retrieveScorePosts()
      for post in scorePosts {
        if checkMatch(post, trip: trip) {
          if let postLocation = post.location {
            let distance = postLocation.distance(from: currentLocation)
            var tempMultiplier = Float(800 - distance)
            tempMultiplier = (tempMultiplier > 0) ? tempMultiplier / 250.0 : 0.0
            highestMulitplier = (tempMultiplier > highestMulitplier) ? tempMultiplier : highestMulitplier
          }
        }
      }
    }
    return highestMulitplier
  }
  
  /**
   * Calculate multiplier in realtion arrival time.
   */
  static fileprivate func multiplierBasedOnArrivalTime(_ trip: RoutineTrip) -> Float {
    if let time = trip.criterions.time {
      let now = Date()
      let date = DateUtils.convertDateString("\(DateUtils.dateAsDateString(now)) \(time)")
      if date.timeIntervalSinceNow > (60 * 60) * -1 {
        return 1.5
      } else {
        return -3.0
      }
    }
    return 0.0
  }
  
  /**
   * Extracts an score post compative int tuple describing
   * time and date for RoutineTrip.
   */
  static fileprivate func createTimeTuple() -> (dayInWeek: Int, hourOfDay: Int) {
    return (DateUtils.getDayOfWeek(), DateUtils.getHourOfDay())
  }
  
  /**
   * Filters out smart suggestions from list.
   */
  static fileprivate func filterSmartSuggestions(_ routineTrips: [RoutineTrip]) -> [RoutineTrip] {
    var filteredList = [RoutineTrip]()
    for (index, routine) in routineTrips.enumerated() {
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
  static fileprivate func checkMatch(_ post: ScorePost, trip: RoutineTrip) -> Bool {
    return (post.originId == trip.criterions.origin?.siteId &&
      post.destId == trip.criterions.dest?.siteId)
  }
}
