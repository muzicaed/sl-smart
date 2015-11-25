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
      return "Gå"
    }
    
    let friendlyLine = friendlyLineData(segment)
    return "Ta \(friendlyLine.long) mot \(segment.directionText!)"
  }
  
  /**
   * Creates human readable line name.
   */
  static func friendlyLineData(segment: TripSegment) -> (short: String, long: String, icon: String) {
    
    let type = segment.type
    let lineNumber = segment.lineNumber
    
    switch type {
    case .Ship:
      return ("Färja", "Djurgårdsfärjan", "SHIP-NEUTRAL")
    case .Ferry:
      return ("Färja", "Sjövägen (Pendelbåt)", "SHIP-NEUTRAL")
    case .Tram:
      if lineNumber == "7" {
        return ("Spårväg", "Spårvagn linje 7", "TRAM-RAIL")
      } else if lineNumber == "12" {
        return ("Spårväg", "Nockebybanan 12", "TRAM-RAIL")
      } else if lineNumber == "21" {
        return ("Spårväg", "Lidingöbanan 21", "TRAM-RAIL")
      } else if lineNumber == "22" {
        return ("Tvärbana", "Tvärbana 22", "TRAM-RAIL")
      } else if lineNumber == "25" {
        return ("Lokaltåg", "Saltsjöbanan 25", "TRAM-LOCAL")
      } else if lineNumber == "26" {
        return ("Lokaltåg", "Saltsjöbanan 26", "TRAM-LOCAL")
      } else if lineNumber == "27" {
        return ("Lokaltåg", "Roslagsbanan, Kårstalinjen", "TRAM-LOCAL")
      } else if lineNumber == "28" {
        return ("Lokaltåg", "Roslagsbanan, Österskärslinjen", "TRAM-LOCAL")
      } else if lineNumber == "29" {
        return ("Lokaltåg", "Roslagsbanan, Näsbyparkslinjen", "TRAM-LOCAL")
      }
      return ("Spårväg", "Spårvagn linje \(lineNumber!)", "TRAM-RAIL")
    case .Bus:
      if segment.name.lowercaseString.rangeOfString("blåbuss") != nil {
        return ("\(lineNumber!)", "Blåbuss \(lineNumber!)", "BUS-BLUE")
      }
      return ("\(lineNumber!)", "Buss \(lineNumber!)", "BUS-RED")
    case .Metro:
      if lineNumber == "13" || lineNumber == "14" {
        return ("Röda", "Tunnelbanan, röda", "METRO-RED")
      } else if lineNumber == "17" || lineNumber == "18" || lineNumber == "19" {
        return ("Gröna", "Tunnelbanan, gröna", "METRO-GREEN")
      } else if lineNumber == "10" || lineNumber == "11" {
        return ("Blåa", "Tunnelbanan, blåa", "METRO-BLUE")
      }
      return ("T-bana", "Tunnelbanan", "METRO-NEUTRAL")
    case .Train:
      return ("\(lineNumber!)", "Pendeltåg linje \(lineNumber!)", "TRAIN-NEUTRAL")
    case .Narbuss:
      return ("\(lineNumber!)", "Närtrafikens buss \(lineNumber!)", "BUS-NEUTRAL")
    case .Walk:
      return ("Gå", "en promenad", "WALK-NEUTRAL")
    default:
      return ("", "", "")
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