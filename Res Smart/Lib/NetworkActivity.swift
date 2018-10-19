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
    
    static fileprivate var numberOfNetworkCalls = 0
    
    /**
     * Track network activity and handle sysbar indicator.
     */
    static func displayActivityIndicator(_ isDisplay: Bool) {
        if isDisplay {
            numberOfNetworkCalls += 1
        } else {
            numberOfNetworkCalls -= 1
        }
        numberOfNetworkCalls = (numberOfNetworkCalls < 0) ? 0 : numberOfNetworkCalls
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = (numberOfNetworkCalls > 0)
        }    
    }
}
