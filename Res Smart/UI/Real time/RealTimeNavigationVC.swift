//
//  RealTimeNavigationVC.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-01-19.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit

class RealTimeNavigationVC: UINavigationController {

  /**
   * On load
   */
  override func viewDidLoad() {
    if let rootVC = viewControllers.first as? SearchLocationVC {
      rootVC.isLocationForRealTimeSearch = true
    }
  }
}