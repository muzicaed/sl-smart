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
    if step <= 3 {
      migrateVersion_1_5()
    }
    if step <= 4 {
      migrateVersion_1_6()
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
    UserPreferenceStore.sharedInstance.setShouldShowNews(true)
    defaults.setInteger(2, forKey: dataKey)
    defaults.synchronize()    
  }
  
  // Version 1.4
  private static func migrateVersion_1_4() {
    print("Running migration v1.4")
    let routines = RoutineTripsStore.sharedInstance.retriveRoutineTrips()
    for routine in routines {
      if routine.isSmartSuggestion {
        routine.criterions.date = nil
        routine.criterions.time = nil
        RoutineTripsStore.sharedInstance.updateRoutineTrip(routine)
      }
    }
    UserPreferenceStore.sharedInstance.setShouldShowNews(true)
    defaults.setInteger(3, forKey: dataKey)
    defaults.synchronize()
  }
  
  // Version 1.5
  private static func migrateVersion_1_5() {
    print("Running migration v1.5")
    NSUserDefaults.standardUserDefaults().setBool(true, forKey: "res_smart_premium_preference")
    StopsStore.sharedInstance.loadJson()
    SubscriptionStore.sharedInstance.resetTrial()
    UserPreferenceStore.sharedInstance.setShouldShowNews(true)
    defaults.setInteger(4, forKey: dataKey)
    defaults.synchronize()
  }
  
  // Version 1.6
  private static func migrateVersion_1_6() {
    print("Running migration v1.6")
    let criterions = SearchCriterionStore.sharedInstance.retrieveSearchCriterions()
    criterions.unsharp = false
    SearchCriterionStore.sharedInstance.writeLastSearchCriterions(criterions)
    defaults.setInteger(5, forKey: dataKey)
    defaults.synchronize()
  }
}