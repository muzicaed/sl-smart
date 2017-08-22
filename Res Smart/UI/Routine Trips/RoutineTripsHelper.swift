//
//  RoutineTripsHelper.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2017-08-19.
//  Copyright © 2017 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit
import ResStockholmApiKit

class RoutineTripsHelper {

  /**
   * Loading the trip data, and starting background
   * collection of time table data.
   * Will show big spinner when loading.
   */
  static func loadTripData(_ force: Bool) {
    /*
    if RoutineTripsStore.sharedInstance.isRoutineTripsEmpty() {
      isShowInfo = true
      otherRoutineTrips = [RoutineTrip]()
      bestRoutineTrip = nil
      selectedRoutineTrip = nil
      stopLoading()
    } else if shouldReload() || force {
      startLoading()
      RoutineService.findRoutineTrip({ routineTrips in
        let when = DispatchTime.now() + 0.5
        DispatchQueue.main.asyncAfter(deadline: when) {
          if routineTrips.count > 0 {
            self.bestRoutineTrip = routineTrips.first!
            self.otherRoutineTrips = Array(routineTrips[1..<routineTrips.count])
            self.lastUpdated = Date()
          }
          
          NetworkActivity.displayActivityIndicator(false)
          self.stopLoading()
        }
      })
    } else {
      collectionView?.reloadData()
    }
     */
  }
}
