//
//  NetworkActivity.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-02-07.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit

class NetworkActivity {
  
  static private var numberOfNetworkCalls = 0
  
  /**
   * Track network activity and handle sysbar indicator.
   */
  static func displayActivityIndicator(isDisplay: Bool) {
    if isDisplay {
      numberOfNetworkCalls++
    } else {
      numberOfNetworkCalls--
    }
    print(numberOfNetworkCalls)
    assert(numberOfNetworkCalls >= 0, "displayNetworkActivityIndicator aked to hide more then show.")
    UIApplication.sharedApplication().networkActivityIndicatorVisible = (numberOfNetworkCalls > 0)
  }
}