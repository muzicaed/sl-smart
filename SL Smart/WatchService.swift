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
      
      if let routineTrip = DataStore.sharedInstance.retriveRoutineTripOnId(routineTripId) {
        
        ScorePostHelper.changeScoreForRoutineTrip(
          routineTrip.criterions.origin!.siteId,
          destinationId: routineTrip.criterions.dest!.siteId,
          scoreMod: ScorePostHelper.BestTapCountScore)
        
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
        print("Error Could not find routine trip")
        response["error"] = true
        callback(response)
      }
  }
}