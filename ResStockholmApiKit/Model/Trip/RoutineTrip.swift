//
//  RoutineTrip.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-21.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation

public class RoutineTrip: NSObject, NSCoding, NSCopying {
    public let id: String
    public var title: String?
    public var criterions = TripSearchCriterion(origin: nil, dest: nil)
    public var trips = [Trip]()
    public var score = Float(0.0)
    public var isSmartSuggestion = false
    
    public init(id: String, title: String?,
                criterions: TripSearchCriterion, isSmartSuggestion: Bool) {
        self.id = id
        self.title = title
        self.criterions = criterions
        self.isSmartSuggestion = isSmartSuggestion
    }
    
    override public init() {
        self.id = UUID().uuidString
        super.init()
    }
    
    /**
     * Converts into data dictionary for transfer to AppleWatch.
     */
    public func watchTransferData(_ countLimit: Int) -> Dictionary<String, AnyObject> {
        var departureString = ""
        var trasportTrips = [Dictionary<String, AnyObject>]()
        if trips.count > 0 {
            if let segment = trips.first!.tripSegments.first {
                let departure = segment.departureDateTime
                departureString = DateUtils.dateAsDateAndTimeString(departure)
            }
            
            for (index, trip) in trips.enumerated() {
                trasportTrips.append(trip.watchTransferData())
                if index >= countLimit {
                    break
                }
            }
        }
        
        return [
            "id": id as AnyObject,
            "ti": title! as AnyObject,
            "ha": isSmartSuggestion as AnyObject,
            "or": (criterions.origin?.name)! as AnyObject,
            "ds": (criterions.dest?.name)! as AnyObject,
            "dp": departureString as AnyObject,
            "tr": trasportTrips as AnyObject
        ]
    }
    
    // MARK: NSCoding
    
    required convenience public init?(coder aDecoder: NSCoder) {
        let id = aDecoder.decodeObject(forKey: PropertyKey.id) as! String
        let title = aDecoder.decodeObject(forKey: PropertyKey.title) as? String
        let criterions = aDecoder.decodeObject(forKey: PropertyKey.criterions) as! TripSearchCriterion
        let isSmartSuggestion = aDecoder.decodeBool(forKey: PropertyKey.isSmartSuggestion)
        
        self.init(id: id, title: title, criterions: criterions, isSmartSuggestion: isSmartSuggestion)
    }
    
    /**
     * Encode this object
     */
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: PropertyKey.id)
        aCoder.encode(title, forKey: PropertyKey.title)
        aCoder.encode(criterions, forKey: PropertyKey.criterions)
        aCoder.encode(isSmartSuggestion, forKey: PropertyKey.isSmartSuggestion)
    }
    
    struct PropertyKey {
        static let id = "id"
        static let title = "title"
        static let criterions = "criterions"
        static let isSmartSuggestion = "isSmartSuggestion"
    }
    
    // MARK: NSCopying
    
    /**
     * Copy self
     */
    public func copy(with zone: NSZone?) -> Any {
        let copy =  RoutineTrip(
            id: id, title: title,
            criterions: criterions.copy() as! TripSearchCriterion,
            isSmartSuggestion: isSmartSuggestion)
        copy.score = score
        
        for trip in trips {
            copy.trips.append(trip.copy() as! Trip)
        }
        
        return copy
    }
}
