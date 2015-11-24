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
   * Finds the all routine trip based on
   * current position, time and week day.
   * TODO: Only test stub...
   */
  func findRoutineTrip(callback: ([RoutineTrip]) -> Void) {
    let routineTrips = DataStore.sharedInstance.retriveRoutineTrips()
    
    // Simulate loading
    let delay = 2 * Double(NSEC_PER_SEC)  // nanoseconds per seconds
    let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))    
    dispatch_after(dispatchTime, dispatch_get_main_queue(), {
      callback(routineTrips)
    })
  }
}