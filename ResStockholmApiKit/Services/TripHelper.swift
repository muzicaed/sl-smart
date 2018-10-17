//
//  TripEnums.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-23.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation

public class TripHelper {
    
    static let walkColor = UIColor(white: 0.4, alpha: 1.0)
    static let busColor = UIColor(red: 180/255, green: 20/255, blue: 30/255, alpha: 1.0)
    static let blueBusColor = UIColor(red: 0/255, green: 137/255, blue: 202/255, alpha: 1.0)
    static let shipColor = UIColor(red: 0/255, green: 137/255, blue: 202/255, alpha: 1.0)
    
    static let redMetro = UIColor(red: 215/255, green: 39/255, blue: 49/255, alpha: 1.0)
    static let greenMetro = UIColor(red: 15/255, green: 165/255, blue: 90/255, alpha: 1.0)
    static let blueMetro = UIColor(red: 0/255, green: 135/255, blue: 187/255, alpha: 1.0)
    
    static let greenTrain = UIColor(red: 134/255, green: 178/255, blue: 81/255, alpha: 1.0)
    static let pinkTrain = UIColor(red: 202/255, green: 96/255, blue: 150/255, alpha: 1.0)
    
    static let tram7 = UIColor(red: 121/255, green: 126/255, blue: 116/255, alpha: 1.0)
    static let tram12 = UIColor(red: 221/255, green: 126/255, blue: 54/255, alpha: 1.0)
    static let tram21 = UIColor(red: 170/255, green: 119/255, blue: 59/255, alpha: 1.0)
    static let tram22 = UIColor(red: 141/255, green: 81/255, blue: 66/255, alpha: 1.0)
    static let tram25_26 = UIColor(red: 0/255, green: 160/255, blue: 155/255, alpha: 1.0)
    static let tram27_29 = UIColor(red: 146/255, green: 89/255, blue: 145/255, alpha: 1.0)
    
    
    /**
     * Creates a human readable trip segment description.
     */
    public static func friendlyTripSegmentDesc(_ segment: TripSegment) -> String {
        if segment.type == .Walk {
            return String(format: "Walk %d meters".localized, segment.distance!)
        }
        if let dirText = segment.directionText {
            return "\("toward".localized) \(dirText.capitalized)"
        }
        return ""
    }
    
    /**
     * Creates human readable line name.
     */
    public static func friendlyLineData(
        _ segment: TripSegment) -> (short: String, long: String, icon: String, color: UIColor) {
        
        let type = segment.type
        var lineNumber = ""
        if let number = segment.lineNumber {
            lineNumber = number
        }
        switch type {
        case .Ship:
            return ("Båt", "Djurgårdsfärjan", "SHIP", shipColor)
        case .Ferry:
            return ("Båt", "Sjövägen (Pendelbåt)", "SHIP", shipColor)
        case .Tram:
            if lineNumber == "7" {
                return ("\(lineNumber)", "Spårväg City 7", "TRAM", tram7)
            } else if lineNumber == "12" {
                return ("\(lineNumber)", "Nockebybanan 12", "TRAM", tram12)
            } else if lineNumber == "21" {
                return ("\(lineNumber)", "Lidingöbanan 21", "TRAM", tram21)
            } else if lineNumber == "22" {
                return ("\(lineNumber)", "Tvärbana 22", "TRAM", tram22)
            } else if lineNumber == "25" {
                return ("\(lineNumber)", "Saltsjöbanan 25", "TRAM", tram25_26)
            } else if lineNumber == "26" {
                return ("\(lineNumber)", "Saltsjöbanan 26", "TRAM", tram25_26)
            } else if lineNumber == "27" {
                return ("\(lineNumber)", "Roslagsbanan, Kårstalinjen", "TRAM", tram27_29)
            } else if lineNumber == "28" {
                return ("\(lineNumber)", "Roslagsbanan, Österskärslinjen", "TRAM", tram27_29)
            } else if lineNumber == "29" {
                return ("\(lineNumber)", "Roslagsbanan, Näsbyparkslinjen", "TRAM", tram27_29)
            }
            return ("\(lineNumber)", "\("Tram line".localized) \(lineNumber)", "TRAM", UIColor.darkGray)
        case .Bus:
            if segment.name.lowercased().range(of: "blåbuss") != nil {
                return ("\(lineNumber)", "\("Blue bus".localized) \(lineNumber)", "BUS", blueBusColor)
            }
            return ("\(lineNumber)", "\("Bus".localized) \(lineNumber)", "BUS", busColor)
        case .Metro:
            if lineNumber == "13" || lineNumber == "14" {
                return ("\(lineNumber)", "\("Metro red line".localized) \(lineNumber)", "METRO", redMetro)
            } else if lineNumber == "17" || lineNumber == "18" || lineNumber == "19" {
                return ("\(lineNumber)", "\("Metro green line".localized) \(lineNumber)", "METRO", greenMetro)
            } else if lineNumber == "10" || lineNumber == "11" {
                return ("\(lineNumber)", "\("Metro blue line".localized) \(lineNumber)", "METRO", blueMetro)
            }
            return ("T-bana", "Tunnelbanan", "METRO", UIColor.darkGray)
        case .Train:
            if lineNumber == "35" {
                return ("\(lineNumber)", "\("Train line".localized) \(lineNumber)", "TRAIN", pinkTrain)
            }
            return ("\(lineNumber)", "\("Train line".localized) \(lineNumber)", "TRAIN", greenTrain)
        case .Narbuss:
            return ("\(lineNumber)", "Närtrafikens buss \(lineNumber )", "BUS", busColor)
        case .Walk:
            return ("→", "Walk".localized, "WALK", walkColor)
        default:
            return ("", "", "", UIColor.darkGray)
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
    
    // Speical
    case Local = "LOCAL"
    
    // Future
    case Bike = "BIKE"
    case Car = "CAR"
    case Taxi = "TAXI"
    
    public var decisive: String {
        switch self {
        case .Ship:
            return "båten"
        case .Ferry:
            return "färjan"
        case .Tram:
            return "spårvagnen"
        case .Bus:
            return "bussen"
        case .Metro:
            return "t-banan"
        case .Train:
            return "tåget"
        case .Narbuss:
            return "närbussen"
        default:
            return ""
        }
    }
    
    public static func fromCode(code: String) -> TripType {
        switch code {
        case "0":
            return TripType.Train
        case "1":
            return TripType.Metro
        case "2":
            return TripType.Tram
        case "3":
            return TripType.Bus
        case "4":
            fatalError()
        case "5":
            fatalError()
        case "6":
            return TripType.Ferry
        default:
            fatalError()
        }
    }
}
