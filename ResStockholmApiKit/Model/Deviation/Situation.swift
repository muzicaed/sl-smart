//
//  Situation.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-12-10.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation

public class Situation {
    
    public let planned: Bool
    public let trafficLine: String?
    public let statusIcon: String
    public let message: String
    
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
