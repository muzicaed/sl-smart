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
    let step = defaults.integerForKey(dataKey)
    if step <= 1 {
      migrateVersion_1_3()
    }
    if step <= 2 {
      migrateVersion_1_4()
    }
  }
  
  // Version 1.3
  private static func migrateVersion_1_3() {
    print("Running migration v1.3")
    let routines = RoutineTripsStore.sharedInstance.retriveRoutineTrips()
    for routine in routines {
      routine.criterions.numChg = -1
      RoutineTripsStore.sharedInstance.updateRoutineTrip(routine)
    }
    defaults.setInteger(2, forKey: dataKey)
    defaults.synchronize()
  }
  
  // Version 1.4
  private static func migrateVersion_1_4() {}
}