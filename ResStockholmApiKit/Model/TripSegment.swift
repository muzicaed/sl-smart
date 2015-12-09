//
//  TripSegment.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-23.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation

public class TripSegment: NSObject, NSCopying {
  public let index: Int
  public let name: String
  public let type: TripType
  public let directionText: String?
  public let lineNumber: String?
  public let origin: Station
  public let destination: Station
  public let departureDateTime: NSDate
  public let arrivalDateTime: NSDate
  public let distance: Int?
  
  public init(
    index: Int, name: String, type: String, directionText: String?,
    lineNumber: String?, origin: Station, destination: Station,
    departureTime: String, arrivalTime: String,
    departureDate: String, arrivalDate: String,
    distance: Int?) {
      
      self.index = index
      self.name = name
      self.type = TripType(rawValue: type)!
      self.directionText = directionText
      self.lineNumber = lineNumber
      self.origin = origin
      self.destination = destination
      self.departureDateTime =  DateUtils.convertDateString("\(departureDate) \(departureTime)")
      self.arrivalDateTime =  DateUtils.convertDateString("\(arrivalDate) \(arrivalTime)")
      self.distance = distance
  }
  
  // MARK: NSCopying
  
  /**
  * Copy self
  */
  public func copyWithZone(zone: NSZone) -> AnyObject {
    return TripSegment(
      index: index, name: name, type: type.rawValue,
      directionText: directionText, lineNumber: lineNumber,
      origin: origin.copy() as! Station,
      destination: destination.copy() as! Station,
      departureTime: DateUtils.dateAsTimeString(departureDateTime),
      arrivalTime: DateUtils.dateAsTimeString(arrivalDateTime),
      departureDate: DateUtils.dateAsDateString(departureDateTime),
      arrivalDate: DateUtils.dateAsDateString(departureDateTime),
      distance: distance)
  }
}