//
//  TripsIC.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-12-07.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class TripsIC: WKInterfaceController {
  
  var data: Dictionary<String, AnyObject>?
  
  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)
    print("------------------")
    print("awakeWithContext")
    print(context as! Dictionary<String, AnyObject>)
    data = context as? Dictionary<String, AnyObject>
  }
}
