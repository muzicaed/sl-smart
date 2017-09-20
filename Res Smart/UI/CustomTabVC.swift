//
//  CustomTabVC.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-23.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit
import ResStockholmApiKit

class CustomTabVC: UITabBarController {
  
  let notificationCenter = NotificationCenter.default
  var currentTrip: Trip?
  var isPremiumSettingOn = true
  var premiumVC: UIViewController?
  
  /**
   * View is done loading.
   */
  override func viewDidLoad() {
    super.viewDidLoad()
    addObservers()
  }
  
  
  /**
   * Updates the tabs based on premium.
   */
  @objc func updateTabs() {
    isPremiumSettingOn = UserDefaults.standard.bool(forKey: "res_smart_premium_preference")
    if !isPremiumSettingOn && self.tabBar.items!.count == 4 {
      if let count = viewControllers?.count {
        let indexToRemove = 0
        if indexToRemove < count {
          premiumVC = viewControllers?[indexToRemove]
          viewControllers?.remove(at: indexToRemove)
        }
      }
    } else if isPremiumSettingOn && self.tabBar.items!.count == 3 {
      if let vc = premiumVC {
        viewControllers?.insert(vc, at: 0)
      }
    }
  }
  
  /**
   * onTrafficSituations notification handler
   */
  @objc func onTrafficSituations(_ notification: Notification) {
    DispatchQueue.main.async {
      let count = notification.object as! Int
      let noOfTabs = self.tabBar.items!.count
      let items = self.tabBar.items!
      if count > 0 {
        items[noOfTabs - 1].badgeValue = String(count)
      } else {
        items[noOfTabs - 1].badgeValue = nil
      }
    }
  }
  
  // MARK: Private
  
  fileprivate func addObservers() {
    notificationCenter.addObserver(self, selector: #selector(onTrafficSituations(_:)),
                                   name: NSNotification.Name(rawValue: "TrafficSituations"), object: nil)
    notificationCenter.addObserver(self, selector: #selector(updateTabs),
                                   name: NSNotification.Name(rawValue: "UpdateTabs"), object: nil)
  }
  
  deinit{
    notificationCenter.removeObserver(self)
  }
}
