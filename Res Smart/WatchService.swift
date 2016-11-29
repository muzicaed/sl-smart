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
  static func requestRoutineTrips(_ callback: @escaping (Dictionary<String, AnyObject>) -> Void) {
    var response = Dictionary<String, AnyObject>()
    RoutineService.findRoutineTrip({ routineTrips in
      if let bestRoutineTrip = routineTrips.first {
        let bestData = bestRoutineTrip
        response = [
          "b": bestData.watchTransferData(1) as AnyObject,
          "?": true as AnyObject
        ]
        
        var otherRoutines = [Dictionary<String, AnyObject>]()
        if routineTrips.count > 1 {
          for (index, routineTrip) in routineTrips.enumerated() {
            if index != 0 {
              otherRoutines.append(routineTrip.watchTransferData(0))
            }
            if index >= 5 {
              break
            }
          }
        }
        response["o"] = otherRoutines as AnyObject?
      } else {
        response["?"] = false as AnyObject?
      }
      
      callback(response)
    })
  }
  
  /**
   * Search for trips
   */
  static func searchTrips(
    _ routineTripId: String,
    callback: @escaping (Dictionary<String, AnyObject>) -> Void) {
      
      var response: Dictionary<String, AnyObject> = [
        "error": false as AnyObject
      ]
      
      if let routineTrip = RoutineTripsStore.sharedInstance.retriveRoutineTripOnId(routineTripId) {
        
        ScorePostHelper.changeScoreForRoutineTrip(
          routineTrip.criterions.origin!.siteId!,
          destinationId: routineTrip.criterions.dest!.siteId!,
          score: ScorePostHelper.BestTapCountScore)
        
        let crit = routineTrip.criterions.copy() as! TripSearchCriterion
        crit.date = DateUtils.dateAsDateString(Date())
        crit.time = DateUtils.dateAsTimeString(Date())
        
        SearchTripService.tripSearch(crit,
          callback: { resTuple in
            if resTuple.1 != nil {
              response["error"] = true as AnyObject?
            }
            
            var foundTrips = [Dictionary<String, AnyObject>]()
            for trip in resTuple.0 {
              foundTrips.append(trip.watchTransferData())
            }
            response["trips"] = foundTrips as AnyObject?
            callback(response)
            
        })
        
      } else {
        response["error"] = true as AnyObject?
        callback(response)
      }
  }
  
  /**
   * Search last trip made on phone.
   */
  static func lastTripSearch(_ callback: @escaping (Dictionary<String, AnyObject>) -> Void) {
    let crit = SearchCriterionStore.sharedInstance.retrieveSearchCriterions()
    var response: Dictionary<String, AnyObject> = [
      "error": false as AnyObject
    ]
    
    if crit.origin == nil || crit.dest == nil {
      response["trips"] = [Dictionary<String, AnyObject>]() as AnyObject?
      callback(response)
      return
    }
    
    SearchTripService.tripSearch(crit,
      callback: { resTuple in
        if resTuple.1 != nil {
          response["error"] = true as AnyObject?
        }
        
        var foundTrips = [Dictionary<String, AnyObject>]()
        for trip in resTuple.0 {
          foundTrips.append(trip.watchTransferData())
        }
        response["trips"] = foundTrips as AnyObject?
        callback(response)
    })
  }
}
