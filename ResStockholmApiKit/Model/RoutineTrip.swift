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
  public var routine: Routine?
  
  public var origin: Location?
  public var destination: Location?
  public var trips = [Trip]()
  public var score = Float(0.0)
  
  public init(id: String?, title: String?, origin: Location?, destination: Location?, routine: Routine?) {
    if let id = id {
      self.id = id
    } else {
      self.id = NSUUID().UUIDString
    }
    self.title = title
    self.routine = routine
    self.origin = origin
    self.destination = destination
  }
  
  override public init() {
    self.id = NSUUID().UUIDString
    super.init()
    self.routine = Routine()
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
      "tit": title!,
      "oid": origin!.siteId,
      "ori": origin!.name,
      "did": destination!.siteId,
      "des": destination!.name,
      "dep": departureString,
      "trp": trasportTrips
    ]
  }
  
  // MARK: NSCoding
  
  required convenience public init?(coder aDecoder: NSCoder) {
    let id = aDecoder.decodeObjectForKey(PropertyKey.id) as! String
    let title = aDecoder.decodeObjectForKey(PropertyKey.title) as? String
    let routine = aDecoder.decodeObjectForKey(PropertyKey.routine) as? Routine
    let origin = aDecoder.decodeObjectForKey(PropertyKey.origin) as? Location
    let destination = aDecoder.decodeObjectForKey(PropertyKey.destination) as? Location
    self.init(id: id, title: title, origin: origin, destination: destination, routine: routine)
  }
  
  /**
   * Encode this object
   */
  public func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(PropertyKey.id)
    aCoder.encodeObject(title, forKey: PropertyKey.title)
    aCoder.encodeObject(routine, forKey: PropertyKey.routine)
    aCoder.encodeObject(origin, forKey: PropertyKey.origin)
    aCoder.encodeObject(destination, forKey: PropertyKey.destination)
  }
  
  struct PropertyKey {
    static let id = "id"
    static let title = "title"
    static let routine = "routine"
    static let origin = "origin"
    static let destination = "destination"
  }
  
  // MARK: NSCopying
  
  /**
  * Copy self
  */
  public func copyWithZone(zone: NSZone) -> AnyObject {
    let copy =  RoutineTrip(
      id: id, title: title, origin: origin?.copy() as! Location?,
      destination: destination?.copy() as! Location?, routine: routine?.copy() as! Routine?)
    copy.score = score
    
    for trip in trips {
      copy.trips.append(trip.copy() as! Trip)
    }
    
    return copy
  }
}