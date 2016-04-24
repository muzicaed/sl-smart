//
//  SearchCriterionStore.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-22.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation

public class SearchCriterionStore {
  
  private let LastSearchCriterions = "LastSearchCriterions"
  private let defaults = NSUserDefaults.init(suiteName: "group.mikael-hellman.ResSmart")!
  private var cachedSearchCriterions = TripSearchCriterion(originId: "0", destId: "0")
  
  // Singelton pattern
  public static let sharedInstance = SearchCriterionStore()
  
  /**
   * Preloads search criterion
   */
  public func preload() {
    cachedSearchCriterions = retrieveSearchCriterions()
  }
  
  /**
   * Retrive "LastSearchCriterions" from data store
   */
  public func retrieveSearchCriterions() -> TripSearchCriterion {
    if cachedSearchCriterions.origin == nil && cachedSearchCriterions.dest == nil {
      
      if let unarchivedObject = defaults.objectForKey(
        LastSearchCriterions) as? NSData {
          if let crit = NSKeyedUnarchiver.unarchiveObjectWithData(unarchivedObject) as? TripSearchCriterion {
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
  public func writeLastSearchCriterions(criterions: TripSearchCriterion) {
    let archivedObject = NSKeyedArchiver.archivedDataWithRootObject(criterions)
    defaults.setObject(archivedObject, forKey: LastSearchCriterions)
    cachedSearchCriterions = criterions.copy() as! TripSearchCriterion
  }
}