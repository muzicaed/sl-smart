//
//  StaticExit.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-09-07.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation
import CoreLocation

open class StaticExit: NSObject, NSCoding {
    
    open let name: String
    open let location: CLLocation
    open let trainPosition: TrainPosition
    open let changeToLines: [String]
    
    
    /**
     * Standard init
     */
    public init(name: String, location: CLLocation, trainPosition: Int, changeToLines: [String]) {
        self.name = name
        self.location = location
        self.changeToLines = changeToLines
        self.trainPosition = TrainPosition(rawValue: trainPosition)!
    }
    
    public enum TrainPosition: Int {
        case front = 0
        case middle = 1
        case back = 2
    }
    
    // MARK: NSCoding
    
    /**
     * Decoder init
     */
    required convenience public init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObject(forKey: PropertyKey.name) as! String
        let location = aDecoder.decodeObject(forKey: PropertyKey.location) as! CLLocation
        let trainPosition = aDecoder.decodeInteger(forKey: PropertyKey.trainPosition)
        let changeToLines = aDecoder.decodeObject(forKey: PropertyKey.changeToLines)  as! [String]
        
        self.init(name: name, location: location, trainPosition: trainPosition, changeToLines: changeToLines)
    }
    
    /**
     * Encode this object
     */
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(location, forKey: PropertyKey.location)
        aCoder.encode(trainPosition.rawValue, forKey: PropertyKey.trainPosition)
        aCoder.encode(changeToLines, forKey: PropertyKey.changeToLines)
    }
    
    struct PropertyKey {
        static let name = "name"
        static let location = "location"
        static let trainPosition = "trainPosition"
        static let changeToLines = "changeToLines"
    }
}
