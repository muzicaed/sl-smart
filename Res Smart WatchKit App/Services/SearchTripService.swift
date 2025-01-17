//
//  SearchTripService.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-23.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation

class SearchTripService {
  
  private static let api = SLTravelPlannerV2Api()
  
  /**
   * Trip search.
   */
  static func tripSearch(
    criterion: TripSearchCriterion,
    callback: (data: [Trip], error: SLNetworkError?) -> Void) {
      api.tripSearch(criterion) { resTuple in
        var trips = [Trip]()
        if let data = resTuple.data {
          if data.length == 0 {
            callback(data: trips, error: SLNetworkError.NoDataFound)
            return
          }
          trips = self.convertJsonResponse(data)
        }
        callback(data: trips, error: resTuple.error)
      }
  }
  
  // MARK: Private methods
  
  /**
  * Converts the raw json string into array of Station.
  */
  private static func convertJsonResponse(jsonDataString: NSData) -> [Trip] {
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
  private static func convertJsonToTrip(tripJson: JSON) -> Trip {
    let tripSegments = convertJsonToSegments(tripJson["LegList"]["Leg"])
    return Trip(
      durationMin: Int(tripJson["dur"].string!)!,
      noOfChanges: Int(tripJson["chg"].string!)!,
      tripSegments: tripSegments.sort({ $0.index < $1.index }))
  }
  
  /**
   * Converts json to trip segment object.
   */
  private static func convertJsonToSegments(segmentsJson: JSON) -> [TripSegment] {
    var tripSegments = [TripSegment]()
    if let segmentsArr = segmentsJson.array  {
      for segmentJson in segmentsArr {
        
        let segment = convertJsonToTripSegment(segmentJson)
        if !(segment.type == .Walk && segment.distance! < 125) {
          tripSegments.append(segment)
        }
      }
    } else {
      let segment = convertJsonToTripSegment(segmentsJson)
      if !(segment.type == .Walk && segment.distance! < 125) {
        tripSegments.append(segment)
      }
    }
    
    return tripSegments
  }
  
  /**
   * Converts json to trip segment object.
   */
  private static func convertJsonToTripSegment(segmentJson: JSON) -> TripSegment {
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
  private static func convertJsonToStation(stationJson: JSON) -> Station {
    return Station(
      id: Int(stationJson["id"].string!)!,
      name: stationJson["name"].string!,
      cleanName: stationJson["name"].string!,
      area: "")
  }
}