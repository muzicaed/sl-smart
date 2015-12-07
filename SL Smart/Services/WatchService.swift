//
//  WatchService.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-12-07.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation


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
            if index >= 3 {
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
  static func searchTrips(callback: (Dictionary<String, AnyObject>) -> Void) {
    dispatch_async(dispatch_get_main_queue()) {
    }
  }
  
}