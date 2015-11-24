//
//  RoutineService.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-24.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation

class RoutineService {

  // Singelton pattern
  static let sharedInstance = RoutineService()
  
  
  /**
   * Finds the best routine trip based on 
   * current position, time and week day.
   * TODO: Only test stub...
   */
  func findBestRoutineTrip() -> RoutineTrip? {
    let routineTrips = DataStore.sharedInstance.retriveRoutineTrips()
    if routineTrips.count > 0 {
      return routineTrips[0]
    }
    
    return nil
  }
  
  /**
   * Finds other relevant trips based on
   * current position, time and week day.
   * TODO: Only test stub...
   */
  func getOtherTrips() -> [RoutineTrip] {
    var routineTrips = DataStore.sharedInstance.retriveRoutineTrips()
    if routineTrips.count > 1 {
      return Array(routineTrips[1..<routineTrips.count])
    }
    
    return [RoutineTrip]()
  }
}