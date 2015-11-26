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
   * Trip search.
   */
  func tripSearch(criterion: TripSearchCriterion, callback: ([Trip]) -> Void) {
    api.tripSearch(criterion) { data in
      let trips = self.convertJsonResponse(data)
      if trips.count == 0 {
        // Better error here
        fatalError("No trips found...")
      }
      
      let filtered = trips.filter {
        for segment in $0.tripSegments {
          if let dist = segment.distance {
            return (dist > 30) ? true : false
          }
        }
        return true
      }
      callback(filtered)
    }
  }
  
  // MARK: Private methods
  
  /**
   * Converts the raw json string into array of Station.
   */
  private func convertJsonResponse(jsonDataString: NSData) -> [Trip] {
    var result = [Trip]()
    let data = JSON(data: jsonDataString)
    
    if let tripsJson = data["TripList"]["Trip"].array {
      for tripJson in tripsJson {
        result.append(convertJsonToTrip(tripJson))
      }
    } else {
      result.append(convertJsonToTrip(data["TripList"]["Trip"]))
    }
    
    return result
  }
  
  /**
   * Converts json to trip object.
   */
  private func convertJsonToTrip(tripJson: JSON) -> Trip {
    let tripSegments = convertJsonToSegments(tripJson["LegList"]["Leg"])
    return Trip(
      durationMin: Int(tripJson["dur"].string!)!,
      noOfChanges: Int(tripJson["chg"].string!)!,
      tripSegments: tripSegments.sort({ $0.index < $1.index }))
  }
  
  /**
   * Converts json to trip segment object.
   */
  private func convertJsonToSegments(segmentsJson: JSON) -> [TripSegment] {
    var tripSegments = [TripSegment]()
    if let segmentsArr = segmentsJson.array  {
      for segmentJson in segmentsArr {
        tripSegments.append(convertJsonToTripSegment(segmentJson))
      }
    } else {
      tripSegments.append(convertJsonToTripSegment(segmentsJson))
    }
    
    return tripSegments
  }
  
  /**
   * Converts json to trip segment object.
   */
  private func convertJsonToTripSegment(segmentJson: JSON) -> TripSegment {
    let origin = convertJsonToStation(segmentJson["Origin"])
    let destination = convertJsonToStation(segmentJson["Destination"])
    
    let distString = (segmentJson["dist"].string != nil) ? segmentJson["dist"].string! : ""
    
    return TripSegment(
      index: Int(segmentJson["idx"].string!)!,
      name: segmentJson["name"].string!,
      type: segmentJson["type"].string!,
      directionText: segmentJson["dir"].string, lineNumber: segmentJson["line"].string,
      origin: origin, destination: destination,
      departureTime: segmentJson["Origin"]["time"].string!,
      arrivalTime: segmentJson["Destination"]["time"].string!,
      departureDate: segmentJson["Origin"]["date"].string!,
      arrivalDate: segmentJson["Destination"]["date"].string!,
      distance: Int(distString))
  }
  
  /**
   * Converts json to station object.
   */
  private func convertJsonToStation(stationJson: JSON) -> Station {
    return Station(
      id: Int(stationJson["id"].string!)!,
      name: stationJson["name"].string!,
      cleanName: stationJson["name"].string!,
      area: "",
      xCoord: 0,
      yCoord: 0)
  }
}