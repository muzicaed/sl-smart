//
//  Stop.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-01-15.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation
import CoreLocation

open class Stop {
    public let id: String
    public let name: String
    public var depDate: Date?
    public var location: CLLocation
    public let type: TripType
    public let exits: [StaticExit]
    
    init(id: String, name: String, location: CLLocation, type: TripType,
         exits: [StaticExit], depDate: String?, depTime: String?) {
        
        self.id = id
        self.name = name
        self.location = location
        self.type = type
        self.exits = exits
        
        if let date = depDate, let time = depTime {
            self.depDate = DateUtils.convertDateString("\(date) \(time)")
        }
    }
}
