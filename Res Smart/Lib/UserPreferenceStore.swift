//
//  UserPreferenceStore.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-03-06.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation

public class UserPreferenceStore {
  
  private let LastRealTimeTripType = "USER-LastRealTimeTripType"
  private let ShouldShowNews = "USER-ShouldShowNews"
  private let defaults = NSUserDefaults.standardUserDefaults()
  private var lastRealTimeTripTypeCache: String?
  private var shouldShowNewsCache: Bool?
  
  // Singelton pattern
  static let sharedInstance = UserPreferenceStore()
  
  /**
   * Returns user's last real time trip type.
   */
  func getLastRealTimeTripType() -> String? {
    if lastRealTimeTripTypeCache == nil {
      lastRealTimeTripTypeCache = defaults.stringForKey(LastRealTimeTripType)
    }
    
    return lastRealTimeTripTypeCache
  }

  /**
   * Set user's last real time trip type.
   */
  func setLastRealTimeTripType(lastRealTimeTripType: String) {
    lastRealTimeTripTypeCache = lastRealTimeTripType
    defaults.setObject(lastRealTimeTripTypeCache, forKey: LastRealTimeTripType)
  }
  
  /**
   * Returns if news should be displayed.
   */
  func shouldShowNews() -> Bool {
    if shouldShowNewsCache == nil {
      shouldShowNewsCache = defaults.boolForKey(ShouldShowNews)
    }
    
    return shouldShowNewsCache!
  }
  
  /**
   * Set user's last real time trip type.
   */
  func setShouldShowNews(shouldShowNews: Bool) {
    shouldShowNewsCache = shouldShowNews
    defaults.setBool(shouldShowNewsCache!, forKey: ShouldShowNews)
  }
}
