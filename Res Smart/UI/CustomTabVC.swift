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
  
  /**
   * View is done loading.
   */
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = StyleHelper.sharedInstance.background
    for item in self.tabBar.items! as [UITabBarItem] {
      if let image = item.image {
        item.image = image.imageWithColor(
          UIColor(white: 0.0, alpha: 0.75)).imageWithRenderingMode(.AlwaysOriginal)
      }
    }
    
    notificationCenter.addObserver(self,
      selector: Selector("onTrafficSituations:"),
      name: "TrafficSituations", object: nil)
  }
  
  /**
   * onTrafficSituations notification handler
   */
  @objc func onTrafficSituations(notification: NSNotification) {
    let count = notification.object as! Int
    let items = self.tabBar.items!
    if count > 0 {
      items[2].badgeValue = String(count)
    }
  }
}