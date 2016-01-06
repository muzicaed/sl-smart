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
   * Get local expire date.
   */
  func getLocalExpireDate() -> NSDate? {
    let endDate = defaults.objectForKey(SubscriptionEndDate) as? NSDate
    
    // TODO: REMOVE TEST OUTPUT
    if let date = endDate {
      print("getLocalExpireDate: \(DateUtils.dateAsDateAndTimeString(date))")
    } else {
      print("getLocalExpireDate: None")    
    }
    return endDate
  }
  
  /**
   * Set a renewed subscription date.
   */
  func setNewSubscriptionDate(endDate: NSDate) {
    print("Set end date: \(DateUtils.dateAsDateAndTimeString(endDate))")
    print(endDate.timeIntervalSinceNow)
    isSubscribedCache = true
    defaults.setBool(isSubscribedCache!, forKey: SubscriptionState)
    defaults.setObject(endDate, forKey: SubscriptionEndDate)
    defaults.synchronize()
  }
  
  /**
   * Set subscription have expired.
   */
  func setSubscriptionHaveExpired() {
    print("Set subscription expired.")
    isSubscribedCache = false
    defaults.setBool(isSubscribedCache!, forKey: SubscriptionState)
    defaults.setObject(nil, forKey: SubscriptionEndDate)
    defaults.synchronize()
  }
}