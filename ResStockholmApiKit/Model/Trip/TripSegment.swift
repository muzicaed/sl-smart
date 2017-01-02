//
//  TripSegment.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-23.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import CoreLocation

open class TripSegment: NSObject, NSCopying {
  open let index: Int
  open let name: String
  open let type: TripType
  open let directionText: String?
  open let lineNumber: String?
  open let origin: Location
  open let destination: Location
  open let departureDateTime: Date
  open let arrivalDateTime: Date
  open let distance: Int?
  open let isRealtime: Bool
  open let journyRef: String?
  open let geometryRef: String?
  open let rtuMessages: String?
  open let notes: String?
  open let isWarning: Bool
  open let durationInMin: Int
  open let isReachable: Bool
  open let isCancelled: Bool
  open var trainPositionText: String? = nil
  open var exitText = ""
  
  open var stops = [Stop]()
  
  public init(
    index: Int, name: String, type: String, directionText: String?,
    lineNumber: String?, origin: Location, destination: Location,
    departureTime: String, arrivalTime: String,
    departureDate: String, arrivalDate: String,
    distance: Int?, isRealtime: Bool, journyRef: String?, geometryRef: String?,
    rtuMessages: String?, notes: String?, isWarning: Bool,
    isReachable: Bool, isCancelled: Bool) {
    
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
    self.rtuMessages = rtuMessages
    self.notes = notes
    self.isWarning = isWarning
    self.isReachable = isReachable
    self.isCancelled = isCancelled
    
    self.durationInMin = Int(self.arrivalDateTime.timeIntervalSince(self.departureDateTime) / 60)
  }
  
  // MARK: NSCopying
  
  /**
   * Copy self (Stops & route line locations are not copied!)
   */
  open func copy(with zone: NSZone?) -> Any {
    let seg = TripSegment(
      index: index, name: name, type: type.rawValue,
      directionText: directionText, lineNumber: lineNumber,
      origin: origin.copy() as! Location,
      destination: destination.copy() as! Location,
      departureTime: DateUtils.dateAsTimeString(departureDateTime),
      arrivalTime: DateUtils.dateAsTimeString(arrivalDateTime),
      departureDate: DateUtils.dateAsDateString(departureDateTime),
      arrivalDate: DateUtils.dateAsDateString(departureDateTime),
      distance: distance, isRealtime: isRealtime, journyRef: journyRef, geometryRef: geometryRef,
      rtuMessages: rtuMessages, notes: notes, isWarning: isWarning,
      isReachable: isReachable, isCancelled: isCancelled)
    
    return seg
  }
}
