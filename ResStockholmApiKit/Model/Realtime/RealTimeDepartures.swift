//
//  RealTimeDepartures.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-01-19.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation

open class RealTimeDepartures {
  
  open let latestUpdated: Date?
  open let dataAge: Int
  open var busses = [String: [RTBus]]()
  open var metros = [String: [RTMetro]]()
  open var trains = [String: [RTTrain]]()
  open var trams = [String: [RTTram]]()
  open var localTrams = [String: [RTTram]]()
  open var boats = [String: [RTBoat]]()
  open var deviations = [String]()
  
  /**
   * Init
   */
  init(lastUpdated: String?, dataAge: Int) {
    if let dateString = lastUpdated {
      self.latestUpdated = RealTimeDepartures.convertDate(dateString)
    } else {
      self.latestUpdated = nil
    }
    self.dataAge = dataAge
  }
  
  /**
   * Converts string to date.
   */
  fileprivate static func convertDate(_ dateStr: String) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    return dateFormatter.date(from: dateStr)!
  }
}
