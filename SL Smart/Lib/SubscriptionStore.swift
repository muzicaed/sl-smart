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
  private var isSubscribedCache: Bool?
  
  // Singelton pattern
  static let sharedInstance = SubscriptionStore()
  
  /**
   * Check if user have a active subscription.
   */
  func isSubscribed() -> Bool {
    // TODO: REMOVE THIS BETA TEST CODE!!!!
    return true
    
    if isSubscribedCache == nil {
      isSubscribedCache = defaults.boolForKey(SubscriptionState)
    }
    
    return isSubscribedCache!
  }
  
  /**
   * Check if expired date have passed.
   */
  func hasExpired() -> Bool {
    if let endDate = defaults.objectForKey(SubscriptionEndDate) as? NSDate {
      print("Stored end date: \(DateUtils.dateAsDateAndTimeString(endDate))")
      if NSDate().timeIntervalSinceDate(endDate) > 0 {
        print("EXPIRED")
        return true
      }
    }
    return false
  }
  
  /**
   * Store in data store.
   */
  func setSubscribedDate(endDate: NSDate) {
    var isSubscribed = false
    print("Set end date: \(DateUtils.dateAsDateAndTimeString(endDate))")
    print(endDate.timeIntervalSinceNow)
    if endDate.timeIntervalSinceNow > 0 {
      isSubscribed = true
    }
    
    isSubscribedCache = isSubscribed
    defaults.setBool(isSubscribed, forKey: SubscriptionState)
    defaults.setObject(endDate, forKey: SubscriptionEndDate)
    defaults.synchronize()
  }
}