//
//  RealTimeDepartures.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-01-19.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation

public class RealTimeDepartures {

  public let latestUpdated: NSDate
  public let dataAge: Int
  public var busses = [String: [RTBus]]()
  public var greenMetros = [String: [RTMetro]]()
  public var blueMetros = [String: [RTMetro]]()
  public var redMetros = [String: [RTMetro]]()
  public var trains = [String: [RTTrain]]()
  public var trams = [String: [RTTram]]()
  public var localTrams = [String: [RTTram]]()
  public var ships = [String]()
  public var deviations = [String]()
  
  /**
   * Init
   */
  init(lastUpdated: String, dataAge: Int) {  
      self.latestUpdated = RealTimeDepartures.convertDate(lastUpdated)
      self.dataAge = dataAge
  }
  
  /**
   * Converts string to date.
   */
  private static func convertDate(dateStr: String) -> NSDate {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    return dateFormatter.dateFromString(dateStr)!
  }
}
