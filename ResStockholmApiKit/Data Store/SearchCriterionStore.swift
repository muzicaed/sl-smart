//
//  SearchCriterionStore.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-22.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation

open class SearchCriterionStore {
  
  fileprivate let LastSearchCriterions = "LastSearchCriterions"
  fileprivate let defaults = UserDefaults.init(suiteName: "group.mikael-hellman.ResSmart")!
  fileprivate var cachedSearchCriterions = TripSearchCriterion(originId: "0", destId: "0")
  
  // Singelton pattern
  open static let sharedInstance = SearchCriterionStore()
  
  /**
   * Retrive "LastSearchCriterions" from data store
   */
  open func retrieveSearchCriterions() -> TripSearchCriterion {
    if cachedSearchCriterions.origin == nil && cachedSearchCriterions.dest == nil {
      if let unarchivedObject = defaults.object(
        forKey: LastSearchCriterions) as? Data {
          if let crit = NSKeyedUnarchiver.unarchiveObject(with: unarchivedObject) as? TripSearchCriterion {
            cachedSearchCriterions = crit
            return cachedSearchCriterions
          }
      }
    }
    return cachedSearchCriterions
  }
  
  /**
   * Store "LastSearchCriterions" in data store.
   */
  open func writeLastSearchCriterions(_ criterions: TripSearchCriterion) {
    let archivedObject = NSKeyedArchiver.archivedData(withRootObject: criterions)
    defaults.set(archivedObject, forKey: LastSearchCriterions)
    cachedSearchCriterions = criterions.copy() as! TripSearchCriterion
    defaults.synchronize()
  }
}
