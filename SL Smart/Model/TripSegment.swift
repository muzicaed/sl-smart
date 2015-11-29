//
//  TripSegment.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-23.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation

class TripSegment: NSObject, NSCopying {
  let index: Int
  let name: String
  let type: TripType
  let directionText: String?
  let lineNumber: String?
  let origin: Station
  let destination: Station
  let departureDateTime: NSDate
  let arrivalDateTime: NSDate
  let distance: Int?
  
  init(
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
      self.departureDateTime =  Utils.convertDateString("\(departureDate) \(departureTime)")
      self.arrivalDateTime =  Utils.convertDateString("\(arrivalDate) \(arrivalTime)")
      self.distance = distance
  }
  
  // MARK: NSCopying
  
  /**
  * Copy self
  */
  func copyWithZone(zone: NSZone) -> AnyObject {
    return TripSegment(
      index: index, name: name, type: type.rawValue,
      directionText: directionText, lineNumber: lineNumber,
      origin: origin.copy() as! Station,
      destination: destination.copy() as! Station,
      departureTime: Utils.dateAsTimeString(departureDateTime),
      arrivalTime: Utils.dateAsTimeString(arrivalDateTime),
      departureDate: Utils.dateAsDateString(departureDateTime),
      arrivalDate: Utils.dateAsDateString(departureDateTime),
      distance: distance)
  }
}