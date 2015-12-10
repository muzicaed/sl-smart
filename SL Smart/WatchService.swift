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
    originId: Int, destinationId: Int,
    callback: (Dictionary<String, AnyObject>) -> Void) {
      
      ScorePostHelper.addScoreForSelectedRoutineTrip(originId, destinationId: destinationId)
      var response: Dictionary<String, AnyObject> = [
        "error": false
      ]
      let date = NSDate(timeIntervalSinceNow: (60 * 5) * -1)
      let criterions = TripSearchCriterion(originId: originId, destId: destinationId)
      criterions.date = DateUtils.dateAsDateString(date)
      criterions.time = DateUtils.dateAsTimeString(date)
      
      SearchTripService.tripSearch(criterions,
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