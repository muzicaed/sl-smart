//
//  RTTransportBase.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-01-19.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation

public class RTTransportBase {

  public let stopAreaName: String
  public let lineNumber: String
  public let destination: String
  public let timeTabledDateTime: NSDate
  public let expectedDateTime: NSDate
  public let displayTime: String
  public let deviations: [String]
  public let journeyDirection: Int

  
  /**
   * Init
   */
  init(stopAreaName: String, lineNumber: String, destination: String,
    timeTabledDateTime: String, expectedDateTime: String, displayTime: String,
    deviations: [String], journeyDirection: Int) {
  
      self.stopAreaName = stopAreaName
      self.lineNumber = lineNumber
      self.destination = destination
      self.timeTabledDateTime = RTTransportBase.convertDate(timeTabledDateTime)
      self.expectedDateTime = RTTransportBase.convertDate(expectedDateTime)
      self.displayTime = displayTime
      self.deviations = deviations
      self.journeyDirection = journeyDirection
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
