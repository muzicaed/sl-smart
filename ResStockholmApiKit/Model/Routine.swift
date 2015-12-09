//
//  Routine.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-22.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation

public class Routine: NSObject, NSCoding, NSCopying {
  
  public var week = RoutineWeek.WeekDays
  public var time = RoutineTime.Morning
  
  override init() {}
  
  public init(week: RoutineWeek, time: RoutineTime) {
    self.week = week
    self.time = time
  }
  
  // MARK: NSCoding
  
  /**
  * Decoder init
  */
  public required convenience init?(coder aDecoder: NSCoder) {
    let week = RoutineWeek.init(rawValue: aDecoder.decodeIntegerForKey(PropertyKey.week))!
    let time = RoutineTime.init(rawValue: aDecoder.decodeIntegerForKey(PropertyKey.time))!
    
    self.init(week: week, time: time)
  }
  
  /**
   * Encode this object
   */
  public func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeInteger(week.rawValue, forKey: PropertyKey.week)
    aCoder.encodeInteger(time.rawValue, forKey: PropertyKey.time)
  }
  
  struct PropertyKey {
    static let week = "week"
    static let time = "time"
  }
  
  // MARK: NSCopying
  
  /**
  * Copy self
  */
  public func copyWithZone(zone: NSZone) -> AnyObject {
    return Routine(week: RoutineWeek(rawValue: week.rawValue)!, time: RoutineTime(rawValue: time.rawValue)!)
  }
}


public enum RoutineWeek: Int {
  case WeekDays = 0
  case WeekEnds = 1
  
  public func toFriendlyString() -> String {
    switch self {
    case .WeekDays:
      return "vardagar"
    case .WeekEnds:
      return "helger"
    }
  }
}

public enum RoutineTime: Int {
  case Morning = 0
  case Day = 1
  case Evening = 2
  case Night = 3
  
  public func toFriendlyString() -> String {
    switch self {
    case .Morning:
      return "Morgon"
    case .Day:
      return "Dagtid"
    case .Evening:
      return "Kvällar"
    case .Night:
      return "Nätter"
    }
  }
}