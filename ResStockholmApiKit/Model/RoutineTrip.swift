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
  
  public init(id: String, title: String?, criterions: TripSearchCriterion) {
    self.id = id
    self.title = title
    self.criterions = criterions
  }
  
  override public init() {
    self.id = NSUUID().UUIDString
    super.init()
  }
  
  /**
   * Converts into data dictionary for transfer to AppleWatch.
   */
  public func watchTransferData() -> Dictionary<String, AnyObject> {
    var departureString = ""
    if trips.count > 0 {
      let departure = trips.first!.tripSegments.first!.departureDateTime
      departureString = DateUtils.dateAsDateAndTimeString(departure)
    }
    
    var trasportTrips = [Dictionary<String, AnyObject>]()
    if trips.count > 0 {
      for (index, trip) in trips.enumerate() {
        trasportTrips.append(trip.watchTransferData())
        if index > 4 {
          break
        }
      }
    }
    
    return [
      "id": id,
      "tit": title!,
      "ori": (criterions.origin?.name)!,
      "des": (criterions.dest?.name)!,
      "dep": departureString,
      "trp": trasportTrips
    ]
  }
  
  // MARK: NSCoding
  
  required convenience public init?(coder aDecoder: NSCoder) {
    let id = aDecoder.decodeObjectForKey(PropertyKey.id) as! String
    let title = aDecoder.decodeObjectForKey(PropertyKey.title) as? String
    let criterions = aDecoder.decodeObjectForKey(PropertyKey.criterions) as! TripSearchCriterion
    
    self.init(id: id, title: title, criterions: criterions)
  }
  
  /**
   * Encode this object
   */
  public func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(id, forKey: PropertyKey.id)
    aCoder.encodeObject(title, forKey: PropertyKey.title)
    aCoder.encodeObject(criterions, forKey: PropertyKey.criterions)
  }
  
  struct PropertyKey {
    static let id = "id"
    static let title = "title"
    static let criterions = "criterions"
  }
  
  // MARK: NSCopying
  
  /**
  * Copy self
  */
  public func copyWithZone(zone: NSZone) -> AnyObject {
    let copy =  RoutineTrip(
      id: id, title: title,
      criterions: criterions.copy() as! TripSearchCriterion)
    copy.score = score
    
    for trip in trips {
      copy.trips.append(trip.copy() as! Trip)
    }
    
    return copy
  }
}