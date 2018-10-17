//
//  Situation.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-12-10.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation

open class Situation {
    
    open let planned: Bool
    open let trafficLine: String?
    open let statusIcon: String
    open let message: String
    
    /**
     * Standard init
     */
    init (planned: Bool, trafficLine: String?, statusIcon: String, message: String) {
        self.planned = planned
        self.trafficLine = trafficLine
        self.statusIcon = statusIcon
        self.message = message
    }
}
