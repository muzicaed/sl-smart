//
//  ScorePost.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-29.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import CoreLocation

open class ScorePost: NSObject, NSCoding, NSCopying {
    
    open var dayInWeek = 0
    open var hourOfDay = 0
    open var originId = "0"
    open var destId = "0"
    open var score = Float(0.0)
    open var location: CLLocation?
    
    /**
     * Standard init
     */
    public init(dayInWeek: Int, hourOfDay: Int, originId: String, destId: String,
                score: Float, location: CLLocation?) {
        self.dayInWeek = dayInWeek
        self.hourOfDay = hourOfDay
        self.originId = originId
        self.destId = destId
        self.score = score
        self.location = location
    }
    
    // MARK: NSCoding
    
    /**
     * Decoder init
     */
    required convenience public init?(coder aDecoder: NSCoder) {
        let dayInWeek = aDecoder.decodeInteger(forKey: PropertyKey.dayInWeek)
        let hourOfDay = aDecoder.decodeInteger(forKey: PropertyKey.hourOfDay)
        let originId = aDecoder.decodeObject(forKey: PropertyKey.originId) as! String
        let destId = aDecoder.decodeObject(forKey: PropertyKey.destId) as! String
        let score = aDecoder.decodeFloat(forKey: PropertyKey.score)
        let location = aDecoder.decodeObject(forKey: PropertyKey.location) as! CLLocation?
        
        self.init(
            dayInWeek: dayInWeek, hourOfDay: hourOfDay,
            originId: originId, destId: destId,
            score: score, location: location)
    }
    
    /**
     * Encode this object
     */
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(dayInWeek, forKey: PropertyKey.dayInWeek)
        aCoder.encode(hourOfDay, forKey: PropertyKey.hourOfDay)
        aCoder.encode(originId, forKey: PropertyKey.originId)
        aCoder.encode(destId, forKey: PropertyKey.destId)
        aCoder.encode(score, forKey: PropertyKey.score)
        aCoder.encode(location, forKey: PropertyKey.location)
    }
    
    struct PropertyKey {
        static let dayInWeek = "dayInWeek"
        static let hourOfDay = "hourOfDay"
        static let originId = "originId"
        static let destId = "destId"
        static let score = "score"
        static let location = "location"
    }
    
    // MARK: NSCopying
    
    /**
     * Copy self
     */
    open func copy(with zone: NSZone?) -> Any {
        var locationCopy: CLLocation? = nil
        if let location = location {
            locationCopy = location.copy() as? CLLocation
        }
        
        return ScorePost(
            dayInWeek: dayInWeek, hourOfDay: hourOfDay,
            originId: originId, destId: destId, score: score, location: locationCopy)
    }
}
