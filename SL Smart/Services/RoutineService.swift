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
    let nearbyStations = StationSearchService.searchNearby()
    var allRoutineTrips = DataStore.sharedInstance.retriveRoutineTrips()
    
//    allRoutineTrips = score
    
    let prioList = allRoutineTrips.sort {$0.score > $1.score}
    callback(Array(prioList[0..<2]) as [RoutineTrip])
  }
}