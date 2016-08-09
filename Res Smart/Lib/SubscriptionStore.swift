//
//  SubscriptionStore.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2016-01-03.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation
import ResStockholmApiKit

public class SubscriptionStore {
  
  private let SubscriptionState = "SubscriptionState"
  private let SubscriptionEndDate = "SubscriptionEndDate"
  private let TrialStartDate = "TrialStartDate"
  private let defaults = NSUserDefaults.standardUserDefaults()
  private var isSubscribedCache: Bool?
  
  // Singelton pattern
  static let sharedInstance = SubscriptionStore()
  
  /**
   * Check if user have a active subscription.
   */
  func isSubscribed() -> Bool {
    // TODO PAY: Remove this
    return true
    
    if isSubscribedCache == nil {
      isSubscribedCache = defaults.boolForKey(SubscriptionState)
    }
    
    return isSubscribedCache!
  }
  
  /**
   * Check if user have a active trial.
   */
  func isTrial() -> Bool {
    if !isSubscribed() {
      if let trialEndDate = defaults.objectForKey(TrialStartDate) as? NSDate {
        return NSDate().timeIntervalSinceDate(trialEndDate) < (60 * 5) // TODO: Change from 5 min.
      }
    }
    return false
  }
 
  /**
   * Get local expire date.
   */
  func getLocalExpireDate() -> NSDate? {
    let endDate = defaults.objectForKey(SubscriptionEndDate) as? NSDate
    return endDate
  }
  
  /**
   * Set a renewed subscription date.
   */
  func setNewSubscriptionDate(endDate: NSDate) {
    isSubscribedCache = true
    defaults.setBool(isSubscribedCache!, forKey: SubscriptionState)
    defaults.setObject(endDate, forKey: SubscriptionEndDate)
    defaults.synchronize()
  }
  
  /**
   * Set subscription have expired.
   */
  func setSubscriptionHaveExpired() {
    isSubscribedCache = false
    defaults.setBool(isSubscribedCache!, forKey: SubscriptionState)
    defaults.setObject(nil, forKey: SubscriptionEndDate)
    defaults.synchronize()
  }
  
  /**
   * Setup trial on app start. 
   * Will not set start date if trial is allready active.
   */
  func setupTrial() {
    let trialEndDate = defaults.objectForKey(TrialStartDate) as? NSDate
    if trialEndDate == nil {
      defaults.setObject(NSDate(), forKey: TrialStartDate)
    }
  }
}