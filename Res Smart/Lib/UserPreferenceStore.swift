//
//  UserPreferenceStore.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-03-06.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation

open class UserPreferenceStore {
  
  fileprivate let LastRealTimeTripType = "USER-LastRealTimeTripType"
  fileprivate let ShouldShowNews = "USER-ShouldShowNews"
  fileprivate let defaults = UserDefaults.standard
  fileprivate var lastRealTimeTripTypeCache: String?
  fileprivate var shouldShowNewsCache: Bool?
  
  // Singelton pattern
  static let sharedInstance = UserPreferenceStore()
  
  /**
   * Returns user's last real time trip type.
   */
  func getLastRealTimeTripType() -> String? {
    if lastRealTimeTripTypeCache == nil {
      lastRealTimeTripTypeCache = defaults.string(forKey: LastRealTimeTripType)
    }
    
    return lastRealTimeTripTypeCache
  }

  /**
   * Set user's last real time trip type.
   */
  func setLastRealTimeTripType(_ lastRealTimeTripType: String) {
    lastRealTimeTripTypeCache = lastRealTimeTripType
    defaults.set(lastRealTimeTripTypeCache, forKey: LastRealTimeTripType)
  }
  
  /**
   * Returns if news should be displayed.
   */
  func shouldShowNews() -> Bool {
    if shouldShowNewsCache == nil {
      shouldShowNewsCache = defaults.bool(forKey: ShouldShowNews)
    }
    
    return shouldShowNewsCache!
  }
  
  /**
   * Set user's last real time trip type.
   */
  func setShouldShowNews(_ shouldShowNews: Bool) {
    shouldShowNewsCache = shouldShowNews
    defaults.set(shouldShowNewsCache!, forKey: ShouldShowNews)
  }
}
