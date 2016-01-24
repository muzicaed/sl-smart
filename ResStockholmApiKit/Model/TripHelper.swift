//
//  TripEnums.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-23.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation

public class TripHelper {
  
  
  /**
   * Creates a human readable trip segment description.
   */
  public static func friendlyTripSegmentDesc(segment: TripSegment) -> String {
    if segment.type == .Walk {
      return "Gå \(segment.distance!) meter"
    }
    
    return "Mot \(segment.directionText!)"
  }
  
  /**
   * Creates human readable line name.
   */
  public static func friendlyLineData(segment: TripSegment) -> (short: String, long: String, icon: String) {
    
    let type = segment.type
    let lineNumber = segment.lineNumber
    
    switch type {
    case .Ship:
      return ("Färja", "Djurgårdsfärjan", "SHIP-NEUTRAL")
    case .Ferry:
      return ("Färja", "Sjövägen (Pendelbåt)", "SHIP-NEUTRAL")
    case .Tram:
      if lineNumber == "7" {
        return ("Spår", "Spårväg City 7", "TRAM-RAIL")
      } else if lineNumber == "12" {
        return ("Spår", "Nockebybanan 12", "TRAM-RAIL")
      } else if lineNumber == "21" {
        return ("Spår", "Lidingöbanan 21", "TRAM-RAIL")
      } else if lineNumber == "22" {
        return ("Tvär", "Tvärbana 22", "TRAM-RAIL")
      } else if lineNumber == "25" {
        return ("Lokal", "Saltsjöbanan 25", "TRAM-LOCAL")
      } else if lineNumber == "26" {
        return ("Lokal", "Saltsjöbanan 26", "TRAM-LOCAL")
      } else if lineNumber == "27" {
        return ("Lokal", "Roslagsbanan, Kårstalinjen", "TRAM-LOCAL")
      } else if lineNumber == "28" {
        return ("Lokal", "Roslagsbanan, Österskärslinjen", "TRAM-LOCAL")
      } else if lineNumber == "29" {
        return ("Lokal", "Roslagsbanan, Näsbyparkslinjen", "TRAM-LOCAL")
      }
      return ("Spår", "Spårvagn linje \(lineNumber!)", "TRAM-RAIL")
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
      return ("\(segment.distance!)m", "Gå", "WALK-NEUTRAL")
    default:
      return ("", "", "")
    }
  }
}

public enum TripType: String {
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