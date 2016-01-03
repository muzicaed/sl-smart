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
  private let defaults = NSUserDefaults.standardUserDefaults()
  private var cache: Bool?
  
  // Singelton pattern
  static let sharedInstance = SubscriptionStore()
  
  /**
   * Check if user have a active subscription.
   */
  func isSubscribed() -> Bool {
    if cache == nil {
      cache = defaults.boolForKey(SubscriptionState)
    }
    return cache!
  }
  
  /**
   * Check if subscription has expired
   */
  func hasSubscriptionExpired() -> Bool {
    if isSubscribed() {
      if let endDate = defaults.objectForKey(SubscriptionEndDate) as? NSDate {
        if NSDate().timeIntervalSinceDate(endDate) > 0 {
          cache = false
          return true
        }
      }
    }
    return false
  }
  
  /**
   * Store in data store.
   */
  func setSubscribed(var isSubscribed: Bool, endDate: NSDate) {
    print("------------")
    print(DateUtils.dateAsDateAndTimeString(endDate))
    print(endDate.timeIntervalSinceNow)
    if endDate.timeIntervalSinceNow < 0 {
      isSubscribed = false
    }
    defaults.setBool(isSubscribed, forKey: SubscriptionState)
    defaults.setObject(endDate, forKey: SubscriptionEndDate)
    defaults.synchronize()
    cache = isSubscribed
  }
}