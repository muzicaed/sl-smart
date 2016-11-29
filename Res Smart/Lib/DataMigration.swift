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
  
  fileprivate static let dataKey = "RES-SMART-CURRENT-MIGRATION-STEP"
  fileprivate static let defaults = UserDefaults.init(suiteName: "group.mikael-hellman.ResSmart")!
  
  static func migrateData() {
    
    let step = defaults.integer(forKey: dataKey)
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
  fileprivate static func migrateVersion_1_3() {
    print("Running migration v1.3")
    let routines = RoutineTripsStore.sharedInstance.retriveRoutineTrips()
    for routine in routines {
      routine.criterions.numChg = -1
      RoutineTripsStore.sharedInstance.updateRoutineTrip(routine)
    }
    UserPreferenceStore.sharedInstance.setShouldShowNews(true)
    defaults.set(2, forKey: dataKey)
    defaults.synchronize()    
  }
  
  // Version 1.4
  fileprivate static func migrateVersion_1_4() {
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
    defaults.set(3, forKey: dataKey)
    defaults.synchronize()
  }
  
  // Version 1.5
  fileprivate static func migrateVersion_1_5() {
    print("Running migration v1.5")
    UserDefaults.standard.set(true, forKey: "res_smart_premium_preference")
    StopsStore.sharedInstance.loadJson()
    SubscriptionStore.sharedInstance.resetTrial()
    UserPreferenceStore.sharedInstance.setShouldShowNews(true)
    defaults.set(4, forKey: dataKey)
    defaults.synchronize()
  }
  
  // Version 1.6
  fileprivate static func migrateVersion_1_6() {
    print("Running migration v1.6")
    let criterions = SearchCriterionStore.sharedInstance.retrieveSearchCriterions()
    criterions.unsharp = false
    SearchCriterionStore.sharedInstance.writeLastSearchCriterions(criterions)
    defaults.set(5, forKey: dataKey)
    defaults.synchronize()
  }
}
