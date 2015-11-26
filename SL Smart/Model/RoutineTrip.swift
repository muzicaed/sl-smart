//
//  RoutineTrip.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-21.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation

class RoutineTrip: NSObject, NSCoding {
  var title: String?
  var routine: Routine?
  var origin: Station?
  var destination: Station?
  var trips = [Trip]()
  
  init(title: String?, origin: Station?, destination: Station?, routine: Routine?) {
    self.title = title
    self.routine = routine
    self.origin = origin
    self.destination = destination
  }
  
  override init() {
    super.init()
    self.routine = Routine()
  }

  // MARK: NSCoding
  
  required convenience init?(coder aDecoder: NSCoder) {
    let title = aDecoder.decodeObjectForKey(PropertyKey.title) as? String
    let routine = aDecoder.decodeObjectForKey(PropertyKey.routine) as? Routine
    let origin = aDecoder.decodeObjectForKey(PropertyKey.origin) as? Station
    let destination = aDecoder.decodeObjectForKey(PropertyKey.destination) as? Station
    self.init(title: title, origin: origin, destination: destination, routine: routine)
  }
  
  /**
   * Encode this object
   */
  func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(title, forKey: PropertyKey.title)
    aCoder.encodeObject(routine, forKey: PropertyKey.routine)
    aCoder.encodeObject(origin, forKey: PropertyKey.origin)
    aCoder.encodeObject(destination, forKey: PropertyKey.destination)
  }
  
  struct PropertyKey {
    static let title = "title"
    static let routine = "routine"
    static let origin = "origin"
    static let destination = "destination"
  }
}