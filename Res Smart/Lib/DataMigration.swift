//
//  DataMigration.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-02-01.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation
import ResStockholmApiKit

class DataMigration {
  
  private static let dataKey = "RES-SMART-CURRENT-MIGRATION-STEP"
  private static let defaults = NSUserDefaults.init(suiteName: "group.mikael-hellman.ResSmart")!
  
  static func migrateData() {
    // TODO: Add migration version etc.
    let routines = RoutineTripsStore.sharedInstance.retriveRoutineTrips()
    for routine in routines {
      routine.criterions.numChg = -1
      RoutineTripsStore.sharedInstance.updateRoutineTrip(routine)
    }
  }
}