//
//  TripEnums.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-23.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation

class TripHelper {
  
  
  /**
   * Creates a human readable trip segment description.
   */
  static func friendlyTripSegmentDesc(segment: TripSegment) -> String {
    if segment.type == .Walk {
      return "Gå till \(segment.destination.name)"
    }
    
    let friendlyLine = friendlyLineString(segment.type, lineNumber: segment.lineNumber)
    return "Ta \(friendlyLine) mot \(segment.directionText!)"
  }
  
  /**
   * Builds an icon name for the trip segment.
   */
  static func buildSegmentIconName(segment: TripSegment) -> String {
    return "T-Green"
  }
  
  /**
   * Creates human readable line name.
   */
  static func friendlyLineString(type: TripType, lineNumber: String?) -> String {
    switch type {
    case .Ship:
      return "Djurgårdsfärjan"
    case .Ferry:
      return "Sjövägen (Pendelbåt)"
    case .Tram:
      if lineNumber == "12" {
        return "Nockebybanan"
      } else if lineNumber == "21" {
        return "Lidingöbanan"
      } else if lineNumber == "22" {
        return "Tvärbanan"
      } else if lineNumber == "25" || lineNumber == "26" {
        return "Saltsjöbanan"
      } else if lineNumber == "27" || lineNumber == "28" || lineNumber == "29" {
        return "Roslagsbanan"
      }
      return "Spårvagn linje \(lineNumber!)"
    case .Bus:
      return "Buss \(lineNumber!)"
    case .Metro:
      if lineNumber == "13" || lineNumber == "14" {
        return "röda T-banan"
      } else if lineNumber == "17" || lineNumber == "18" || lineNumber == "19" {
        return "gröna T-banan"
      } else if lineNumber == "10" || lineNumber == "11" {
        return "blåa T-banan"
      }
      return "T-bana"
    case .Train:
      return "Pendeltåg mot"
    case .Narbuss:
      return "Buss (Närtrafikens) \(lineNumber!)"
    case .Walk:
      return "Gå"
    default:
      return ""
    }
  }
}

enum TripType: String {
  case Ship = "SHIP"
  case Ferry = "FERRY"
  case Tram = "TRAM"
  case Bus = "BUS"
  case Metro = "METRO"
  case Train = "TRAIN"
  case Narbuss = "NARBUSS"
  case Walk = "WALK"
  // Future
  case Bike = "BIKE"
  case Car = "CAR"
  case Taxi = "TAXI"
}