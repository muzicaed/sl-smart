//
//  StaticStop.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-09-06.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation
import CoreLocation

open class StaticStop: NSObject, NSCoding {
    
    public let stopPointNumber: String
    public let stopPointName: String
    public let stopAreaNumber: String
    public let location: CLLocation
    public let type: TripType
    public var exits: [StaticExit]
    
    /**
     * Standard init
     */
    public init(stopPointNumber: String, stopPointName: String, stopAreaNumber: String, location: CLLocation, type: TripType) {
        self.stopPointNumber = stopPointNumber
        self.stopPointName = stopPointName
        self.stopAreaNumber = stopAreaNumber
        self.location = location
        self.type = type
        self.exits = ExitData.getExits(stopAreaNumber)
    }
    
    // MARK: NSCoding
    
    /**
     * Decoder init
     */
    required convenience public init?(coder aDecoder: NSCoder) {
        let stopPointNumber = aDecoder.decodeObject(forKey: PropertyKey.stopPointNumber) as! String
        let stopPointName = aDecoder.decodeObject(forKey: PropertyKey.stopPointName) as! String
        let stopAreaNumber = aDecoder.decodeObject(forKey: PropertyKey.stopAreaNumber) as! String
        let location = aDecoder.decodeObject(forKey: PropertyKey.location) as! CLLocation
        let type = aDecoder.decodeObject(forKey: PropertyKey.type) as! String
        let exits = aDecoder.decodeObject(forKey: PropertyKey.exits)  as! [StaticExit]
        
        self.init(stopPointNumber: stopPointNumber, stopPointName: stopPointName,
                  stopAreaNumber: stopAreaNumber, location: location, type: TripType(rawValue: type)!)
        self.exits = exits
    }
    
    /**
     * Encode this object
     */
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(stopPointNumber, forKey: PropertyKey.stopPointNumber)
        aCoder.encode(stopPointName, forKey: PropertyKey.stopPointName)
        aCoder.encode(stopAreaNumber, forKey: PropertyKey.stopAreaNumber)
        aCoder.encode(location, forKey: PropertyKey.location)
        aCoder.encode(type.rawValue, forKey: PropertyKey.type)
        aCoder.encode(exits, forKey: PropertyKey.exits)
    }
    
    struct PropertyKey {
        static let stopPointNumber = "stopPointNumber"
        static let stopPointName = "stopPointName"
        static let stopAreaNumber = "stopAreaNumber"
        static let location = "location"
        static let type = "type"
        static let exits = "exits"
    }
}
