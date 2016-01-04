//
//  WatchService.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-12-07.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import ResStockholmApiKit

class WatchService {
  
  /**
   * Request routine trips
   */
  static func requestRoutineTrips(callback: (Dictionary<String, AnyObject>) -> Void) {
    var response = Dictionary<String, AnyObject>()
    RoutineService.findRoutineTrip({ routineTrips in
      if let bestRoutineTrip = routineTrips.first {
        let bestData = bestRoutineTrip
        response = [
          "best": bestData.watchTransferData(),
          "foundData": true
        ]
        
        var otherTrips = [Dictionary<String, AnyObject>]()
        if routineTrips.count > 1 {
          for (index, routineTrip) in routineTrips.enumerate() {
            if index != 0 {
              otherTrips.append(routineTrip.watchTransferData())
            }
            if index >= 5 {
              break
            }
          }
        }
        response["other"] = otherTrips
      } else {
        response["foundData"] = false
      }
      
      callback(response)
    })
  }
  
  /**
   * Search for trips
   */
  static func searchTrips(
    routineTripId: String,
    callback: (Dictionary<String, AnyObject>) -> Void) {
      
      var response: Dictionary<String, AnyObject> = [
        "error": false
      ]
      
      if let routineTrip = RoutineTripsStore.sharedInstance.retriveRoutineTripOnId(routineTripId) {
        
        ScorePostHelper.changeScoreForRoutineTrip(
          routineTrip.criterions.origin!.siteId!,
          destinationId: routineTrip.criterions.dest!.siteId!,
          score: ScorePostHelper.BestTapCountScore)
        
        let crit = routineTrip.criterions.copy() as! TripSearchCriterion
        let date = NSDate(timeIntervalSinceNow: (60 * 5) * -1)
        crit.date = DateUtils.dateAsDateString(date)
        crit.time = DateUtils.dateAsTimeString(date)
        
        SearchTripService.tripSearch(crit,
          callback: { resTuple in
            if resTuple.error != nil {
              response["error"] = true
            }
            
            var foundTrips = [Dictionary<String, AnyObject>]()
            for trip in resTuple.data {
              foundTrips.append(trip.watchTransferData())
            }
            response["trips"] = foundTrips
            callback(response)
            
        })
        
      } else {
        response["error"] = true
        callback(response)
      }
  }
  
  /**
   * Search last trip made on phone.
   */
  static func lastTripSearch(callback: (Dictionary<String, AnyObject>) -> Void) {
    let crit = SearchCriterionStore.sharedInstance.retrieveSearchCriterions()
    var response: Dictionary<String, AnyObject> = [
      "error": false
    ]
    
    if crit.origin == nil || crit.dest == nil {
      response["trips"] = [Dictionary<String, AnyObject>]()
      callback(response)
      return
    }
    
    SearchTripService.tripSearch(crit,
      callback: { resTuple in
        if resTuple.error != nil {
          response["error"] = true
        }
        
        var foundTrips = [Dictionary<String, AnyObject>]()
        for trip in resTuple.data {
          foundTrips.append(trip.watchTransferData())
        }
        response["trips"] = foundTrips
        callback(response)
    })
  }
}