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
  
  let notificationCenter = NSNotificationCenter.defaultCenter()
  var currentTrip: Trip?
  var isPremium = true
  
  /**
   * View is done loading.
   */
  override func viewDidLoad() {
    super.viewDidLoad()
    for item in tabBar.items! as [UITabBarItem] {
      if let image = item.image {
        item.image = image.imageWithColor(
          UIColor(white: 0.0, alpha: 0.75)).imageWithRenderingMode(.AlwaysOriginal)
      }
    }
    addObservers()
  }

  
  /**
   * Updates the tabs based on premium.
   */
  func updateTabs() {
    isPremium = NSUserDefaults.standardUserDefaults().boolForKey("res_smart_premium_preference")
    print(isPremium)
    if !isPremium && self.tabBar.items!.count == 4 {
      let indexToRemove = 0
      if indexToRemove < viewControllers?.count {
        viewControllers?.removeAtIndex(indexToRemove)
        viewControllers = viewControllers
      }
    }
  }
  
  /**
   * View have appeard
   */
  override func viewDidAppear(animated: Bool) {
    if UserPreferenceStore.sharedInstance.shouldShowNews() {
      performSegueWithIdentifier("ShowNews", sender: self)
      UserPreferenceStore.sharedInstance.setShouldShowNews(false)
    }
  }
  
  /**
   * Prepare for segue
   */
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "ShowCurrentTrip" {
      let nav = segue.destinationViewController as! UINavigationController
      let vc = nav.visibleViewController as! CurrentTripVC
      vc.currentTrip = currentTrip
    }
  }
  
  /**
   * onStartTrip notification handler
   * Initiates a current trip.
   */
  @objc func onStartTrip(notification: NSNotification) {
    currentTrip = notification.object as? Trip
    performSegueWithIdentifier("ShowCurrentTrip", sender: self)
  }
  
  /**
   * onTrafficSituations notification handler
   */
  @objc func onTrafficSituations(notification: NSNotification) {
    let count = notification.object as! Int
    let noOfTabs = self.tabBar.items!.count
    let items = self.tabBar.items!
    if count > 0 {
      items[noOfTabs - 1].badgeValue = String(count)
    } else {
      items[noOfTabs - 1].badgeValue = nil
    }
  }
  
  /**
   * onPremiumDisabled notification handler
   */
  @objc func onPremiumDisabled(notification: NSNotification) {
    isPremium = false
    NSUserDefaults.standardUserDefaults().setBool(isPremium, forKey: "res_smart_premium_preference")
    updateTabs()
  }
  
  // MARK: Private
  
  private func addObservers() {
    notificationCenter.addObserver(self, selector: #selector(onTrafficSituations(_:)),
                                   name: "TrafficSituations", object: nil)
    notificationCenter.addObserver(self, selector: #selector(onStartTrip(_:)),
                                   name: "BeginTrip", object: nil)
    notificationCenter.addObserver(self, selector: #selector(onPremiumDisabled(_:)),
                                   name: "PremiumDisabled", object: nil)
  }
  
  deinit{
    notificationCenter.removeObserver(self)
  }
}