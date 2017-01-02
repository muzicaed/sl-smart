//
//  SubscriptionStore.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2016-01-03.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation
import ResStockholmApiKit

open class SubscriptionStore {
  
  fileprivate let SubscriptionState = "SubscriptionState"
  fileprivate let SubscriptionEndDate = "SubscriptionEndDate"
  fileprivate let TrialStartDate = "TrialStartDate"
  fileprivate let defaults = UserDefaults.standard
  fileprivate var isSubscribedCache: Bool?
  
  // Singelton pattern
  static let sharedInstance = SubscriptionStore()
  
  /**
   * Check if user have a active subscription.
   */
  func isSubscribed() -> Bool {
    loadSubscribedCache()
    return (isSubscribedCache! || isTrial())
  }
  
  /**
   * Check if user have a active trial.
   */
  func isTrial() -> Bool {    
    loadSubscribedCache()
    if !isSubscribedCache! {
      if let trialEndDate = defaults.object(forKey: TrialStartDate) as? Date {
        let isTrial = (Date().timeIntervalSince(trialEndDate) < (60 * 60 * 24 * 14))
        return isTrial
      }
    }
    return false
  }
  
  /**
   * Get local expire date.
   */
  func getLocalExpireDate() -> Date? {
    let endDate = defaults.object(forKey: SubscriptionEndDate) as? Date
    return endDate
  }
  
  /**
   * Set a renewed subscription date.
   */
  func setNewSubscriptionDate(_ endDate: Date) {
    isSubscribedCache = true
    defaults.set(isSubscribedCache!, forKey: SubscriptionState)
    defaults.set(endDate, forKey: SubscriptionEndDate)
    defaults.synchronize()
  }
  
  /**
   * Set subscription have expired.
   */
  func setSubscriptionHaveExpired() {
    isSubscribedCache = false
    defaults.set(isSubscribedCache!, forKey: SubscriptionState)
    defaults.set(nil, forKey: SubscriptionEndDate)
    defaults.synchronize()
  }
  
  /**
   * Setup trial on app start.
   * Will not set start date if trial is allready active.
   */
  func setupTrial() {
    let trialEndDate = defaults.object(forKey: TrialStartDate) as? Date
    if trialEndDate == nil {
      defaults.set(Date(), forKey: TrialStartDate)
    }
  }
  
  /**
   * Reset the trial
   */
  func resetTrial() {
    defaults.set(nil, forKey: TrialStartDate)
  }
  
  // MARK: Private
  
  /**
   * Loads is subscribed data
   */
  fileprivate func loadSubscribedCache() {
    if isSubscribedCache == nil {
      isSubscribedCache = defaults.bool(forKey: SubscriptionState)
    }
  }
}
