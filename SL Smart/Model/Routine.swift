//
//  Routine.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-22.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation

class Routine: NSObject, NSCoding {
  
  var week = RoutineWeek.WeekDays
  var time = RoutineTime.Morning
  
  override init() {}
  
  init(week: RoutineWeek, time: RoutineTime) {
    self.week = week
    self.time = time
  }
  
  // MARK: NSCoding
  
  /**
  * Decoder init
  */
  required convenience init?(coder aDecoder: NSCoder) {
    let week = RoutineWeek.init(rawValue: aDecoder.decodeIntegerForKey(PropertyKey.week))!
    let time = RoutineTime.init(rawValue: aDecoder.decodeIntegerForKey(PropertyKey.time))!
    
    self.init(week: week, time: time)
  }
  
  /**
   * Encode this object
   */
  func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeInteger(week.rawValue, forKey: PropertyKey.week)
    aCoder.encodeInteger(time.rawValue, forKey: PropertyKey.time)
  }
  
  struct PropertyKey {
    static let week = "week"
    static let time = "time"
  }
}


enum RoutineWeek: Int {
  case WeekDays = 0
  case WeekEnds = 1
  
  func toFriendlyString() -> String {
    switch self {
    case .WeekDays:
      return "vardagar"
    case .WeekEnds:
      return "helger"
    }
  }
}

enum RoutineTime: Int {
  case Morning = 0
  case Afternoon = 1
  case Evening = 2
  case Night = 3
  
  func toFriendlyString() -> String {
    switch self {
    case .Morning:
      return "Morgon"
    case .Afternoon:
      return "Förmiddagar"
    case .Evening:
      return "Kvällar"
    case .Night:
      return "Nätter"
    }
  }
}