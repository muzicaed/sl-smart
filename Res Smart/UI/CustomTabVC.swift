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
  func updateTabs() {
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
   * View have appeard
   */
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if UserPreferenceStore.sharedInstance.shouldShowNews() {
      performSegue(withIdentifier: "ShowNews", sender: self)
      UserPreferenceStore.sharedInstance.setShouldShowNews(false)
    }
  }
  
  /**
   * Prepare for segue
   */
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "ShowCurrentTrip" {
      let nav = segue.destination as! UINavigationController
      let vc = nav.visibleViewController as! CurrentTripVC
      vc.currentTrip = currentTrip
    }
  }
  
  /**
   * onStartTrip notification handler
   * Initiates a current trip.
   */
  @objc func onStartTrip(_ notification: Notification) {
    currentTrip = notification.object as? Trip
    performSegue(withIdentifier: "ShowCurrentTrip", sender: self)
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
  
  /**
   * onPremiumDisabled notification handler
   */
  @objc func onPremiumDisabled(_ notification: Notification) {
    isPremiumSettingOn = false
    UserDefaults.standard.set(isPremiumSettingOn, forKey: "res_smart_premium_preference")
    updateTabs()
  }
  
  // MARK: Private
  
  fileprivate func addObservers() {
    notificationCenter.addObserver(self, selector: #selector(onTrafficSituations(_:)),
                                   name: NSNotification.Name(rawValue: "TrafficSituations"), object: nil)
    notificationCenter.addObserver(self, selector: #selector(onStartTrip(_:)),
                                   name: NSNotification.Name(rawValue: "BeginTrip"), object: nil)
    notificationCenter.addObserver(self, selector: #selector(onPremiumDisabled(_:)),
                                   name: NSNotification.Name(rawValue: "PremiumDisabled"), object: nil)
  }
  
  deinit{
    notificationCenter.removeObserver(self)
  }
}
