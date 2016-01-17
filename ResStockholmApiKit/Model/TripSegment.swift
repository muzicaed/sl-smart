//
//  TripSegment.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-23.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import CoreLocation

public class TripSegment: NSObject, NSCopying {
  public let index: Int
  public let name: String
  public let type: TripType
  public let directionText: String?
  public let lineNumber: String?
  public let origin: Location
  public let destination: Location
  public let departureDateTime: NSDate
  public let arrivalDateTime: NSDate
  public let distance: Int?
  public let isRealtime: Bool
  public let journyRef: String?
  public let geometryRef: String
  
  public var stops = [Stop]()
  public var routeLineLocations = [CLLocation]()
  
  public init(
    index: Int, name: String, type: String, directionText: String?,
    lineNumber: String?, origin: Location, destination: Location,
    departureTime: String, arrivalTime: String,
    departureDate: String, arrivalDate: String,
    distance: Int?, isRealtime: Bool, journyRef: String?,
    geometryRef: String) {
      
      self.index = index
      self.name = name
      self.type = TripType(rawValue: type)!
      if let dir = directionText {
        self.directionText = StringUtils.fixBrokenEncoding(dir)
      } else {
        self.directionText = nil
      }
      self.lineNumber = lineNumber
      self.origin = origin
      self.destination = destination
      self.departureDateTime =  DateUtils.convertDateString("\(departureDate) \(departureTime)")
      self.arrivalDateTime =  DateUtils.convertDateString("\(arrivalDate) \(arrivalTime)")
      self.distance = distance
      self.isRealtime = isRealtime
      self.journyRef = journyRef
      self.geometryRef = geometryRef
  }
  
  // MARK: NSCopying
  
  /**
  * Copy self (Stops & route line locations are not copied!)
  */
  public func copyWithZone(zone: NSZone) -> AnyObject {
    let seg = TripSegment(
      index: index, name: name, type: type.rawValue,
      directionText: directionText, lineNumber: lineNumber,
      origin: origin.copy() as! Location,
      destination: destination.copy() as! Location,
      departureTime: DateUtils.dateAsTimeString(departureDateTime),
      arrivalTime: DateUtils.dateAsTimeString(arrivalDateTime),
      departureDate: DateUtils.dateAsDateString(departureDateTime),
      arrivalDate: DateUtils.dateAsDateString(departureDateTime),
      distance: distance, isRealtime: isRealtime, journyRef: journyRef,
      geometryRef: geometryRef)

    return seg
  }
}