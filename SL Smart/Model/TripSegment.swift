//
//  TripSegment.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-23.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation

class TripSegment {
  let index: Int
  let type: TripType
  let directionText: String?
  let lineNumber: String?
  let origin: Station
  let destination: Station
  let departureDateTime: NSDate
  let arrivalDateTime: NSDate
  
  init(
    index: Int, type: String, directionText: String?,
    lineNumber: String?, origin: Station, destination: Station,
    departureTime: String, arrivalTime: String,
    departureDate: String, arrivalDate: String) {
      
      self.index = index
      self.type = TripType(rawValue: type)!
      self.directionText = directionText
      self.lineNumber = lineNumber
      self.origin = origin
      self.destination = destination
      self.departureDateTime =  Utils.convertDateString("\(departureDate) \(departureTime)")
      self.arrivalDateTime =  Utils.convertDateString("\(arrivalDate) \(arrivalTime)")
  }
}