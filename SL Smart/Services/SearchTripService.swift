//
//  SearchTripService.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-23.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation

class SearchTripService {
  
  // Singelton pattern
  static let sharedInstance = SearchTripService()
  private let api = SLTravelPlannerV2Api()
  
  /**
   * Simple single trip search.
   * Search only for closest upcoming trip using origin and destination.
   * Return only one trip.
   */
  func simpleSingleTripSearch(origin: Station, destination: Station, callback: (Trip) -> Void) {    
    api.simpleSearch(origin, destination: destination) { data in
      let trips = self.convertJsonResponse(data)
      if trips.count == 0 {
        // Better error here
        fatalError("No trips found...")
      }
      callback(trips[0])
    }
  }
  
  
  /**
   * Converts the raw json string into array of Station.
   */
  private func convertJsonResponse(jsonDataString: NSData) -> [Trip] {
    var result = [Trip]()
    let data = JSON(data: jsonDataString)

    for (_,tripJson):(String, JSON) in data["TripList"]["Trip"] {
      let tripSegments = convertJsonToSegments(tripJson["LegList"]["Leg"])
      let trip = Trip(
        durationMin: Int(tripJson["dur"].string!)!,
        noOfChanges: Int(tripJson["chg"].string!)!,
        tripSegments: tripSegments.sort({ $0.index < $1.index }))
      
      result.append(trip)
    }
    
    return result
  }
  
  /**
   * Converts json to trip segment object.
   */
  private func convertJsonToSegments(segmentsJson: JSON) -> [TripSegment] {
    var tripSegments = [TripSegment]()    
    for (_,segmentJson):(String, JSON) in segmentsJson {
      let tripSegment = TripSegment(
        index: Int(segmentJson["idx"].string!)!,
        type: segmentJson["type"].string!,
        directionText: segmentJson["dir"].string, lineNumber: segmentJson["line"].string,
        origin: convertJsonToStation(segmentJson["Origin"]),
        destination: convertJsonToStation(segmentJson["Destination"]),
        departureTime: segmentJson["Origin"]["time"].string!,
        arrivalTime: segmentJson["Destination"]["time"].string!,
        departureDate: segmentJson["Origin"]["date"].string!,
        arrivalDate: segmentJson["Destination"]["date"].string!)
      
      tripSegments.append(tripSegment)
    }
    
    return tripSegments
  }
  
  /**
   * Converts json to station object.
   */
  private func convertJsonToStation(stationJson: JSON) -> Station {
    return Station(
      id: Int(stationJson["id"].string!)!,
      name: stationJson["name"].string!,
      area: "",
      xCoord: 0,
      yCoord: 0)
  }
}