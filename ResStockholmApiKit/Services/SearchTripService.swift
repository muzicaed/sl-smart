//
//  SearchTripService.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-23.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation

public class SearchTripService {
  
  private static let api = SLTravelPlannerV2Api()
  
  /**
   * Trip search.
   */
  public static func tripSearch(
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
  * Converts the raw json string into array of Trip.
  */
  private static func convertJsonResponse(jsonDataString: NSData) -> [Trip] {
    var result = [Trip]()
    let data = JSON(data: jsonDataString)
    if checkErrors(data) {
      return [Trip]()
    }
    
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
   * Checks if service returned error.
   */
  private static func checkErrors(data: JSON) -> Bool {
    if let errorCode = data["TripList"]["errorCode"].string {
      print("SearchTripService got error: \(data["TripList"]["errorText"].string!) (Code: \(errorCode))")
      return true
    }
    return false
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
        if !(segment.type == .Walk && segment.distance! < 250) {
          tripSegments.append(segment)
        }
      }
    } else {
      let segment = convertJsonToTripSegment(segmentsJson)
      if !(segment.type == .Walk && segment.distance! < 250) {
        tripSegments.append(segment)
      }
    }
    
    return tripSegments
  }
  
  /**
   * Converts json to trip segment object.
   */
  private static func convertJsonToTripSegment(segmentJson: JSON) -> TripSegment {
    let origin = convertJsonToLocation(segmentJson["Origin"])
    let destination = convertJsonToLocation(segmentJson["Destination"])
    
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
   * Converts json to location object.
   */
  private static func convertJsonToLocation(locationJson: JSON) -> Location {    
    return Location(
      id: locationJson["id"].string,
      name: ensureUTF8(locationJson["name"].string!),
      type: locationJson["type"].string!,
      lat: locationJson["lat"].string!,
      lon: locationJson["lon"].string!)
  }
  
  
  /**
   * Ensures the string is UTF8
   */
  private static func ensureUTF8(var string: String) -> String {
    let data = string.dataUsingEncoding(NSISOLatin1StringEncoding, allowLossyConversion: false)!
    let convertedName = NSString(data: data, encoding: NSUTF8StringEncoding)
    if let convName = convertedName {
      string = convName as String
    }
    
    return string
  }
}