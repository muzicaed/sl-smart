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
    self.id = NSUUID().UUIDString
    super.init()
  }
  
  /**
   * Converts into data dictionary for transfer to AppleWatch.
   */
  public func watchTransferData(countLimit: Int) -> Dictionary<String, AnyObject> {
    var departureString = ""
    if trips.count > 0 {
      let departure = trips.first!.tripSegments.first!.departureDateTime
      departureString = DateUtils.dateAsDateAndTimeString(departure)
    }
    
    var trasportTrips = [Dictionary<String, AnyObject>]()
    if trips.count > 0 {
      for (index, trip) in trips.enumerate() {
        trasportTrips.append(trip.watchTransferData())
        if index >= countLimit {
          break
        }
      }
    }
    
    return [
      "id": id,
      "ti": title!,
      "ha": isSmartSuggestion,
      "or": (criterions.origin?.name)!,
      "ds": (criterions.dest?.name)!,
      "dp": departureString,
      "tr": trasportTrips
    ]
  }
  
  // MARK: NSCoding
  
  required convenience public init?(coder aDecoder: NSCoder) {
    let id = aDecoder.decodeObjectForKey(PropertyKey.id) as! String
    let title = aDecoder.decodeObjectForKey(PropertyKey.title) as? String
    let criterions = aDecoder.decodeObjectForKey(PropertyKey.criterions) as! TripSearchCriterion
    let isSmartSuggestion = aDecoder.decodeBoolForKey(PropertyKey.isSmartSuggestion)
    
    self.init(id: id, title: title, criterions: criterions, isSmartSuggestion: isSmartSuggestion)
  }
  
  /**
   * Encode this object
   */
  public func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(id, forKey: PropertyKey.id)
    aCoder.encodeObject(title, forKey: PropertyKey.title)
    aCoder.encodeObject(criterions, forKey: PropertyKey.criterions)
    aCoder.encodeBool(isSmartSuggestion, forKey: PropertyKey.isSmartSuggestion)
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
  public func copyWithZone(zone: NSZone) -> AnyObject {
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