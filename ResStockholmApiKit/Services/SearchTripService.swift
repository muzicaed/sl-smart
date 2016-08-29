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
    
    if data["TripList"].isExists() {
      if let tripsJson = data["TripList"]["Trip"].array {
        for tripJson in tripsJson {
          result.append(convertJsonToTrip(tripJson))
        }
      } else {
        result.append(convertJsonToTrip(data["TripList"]["Trip"]))
      }
    }
    
    return result
  }
  
  /**
   * Checks if service returned error.
   */
  private static func checkErrors(data: JSON) -> Bool {
    if data["TripList"]["errorCode"].string != nil {
      return true
    } else if data["StatusCode"].string != nil {
      return true
    }
    return false
  }
  
  /**
   * Converts json to trip object.
   */
  private static func convertJsonToTrip(tripJson: JSON) -> Trip {
    let tripSegments = convertJsonToSegments(tripJson["LegList"]["Leg"])
    var isValid = true
    if let val = tripJson["valid"].string {
      isValid = (val == "false") ? false : true
    }
    return Trip(
      durationMin: Int(tripJson["dur"].string!)!,
      noOfChanges: Int(tripJson["chg"].string!)!,
      isValid: isValid,
      tripSegments: tripSegments.sort({ $0.index < $1.index }))
  }
  
  /**
   * Converts json to trip segment object.
   */
  private static func convertJsonToSegments(segmentsJson: JSON) -> [TripSegment] {
    var tripSegments = [TripSegment]()
    if segmentsJson.isExists() {
      if let segmentsArr = segmentsJson.array  {
        for segmentJson in segmentsArr {
          if segmentsJson.isExists() {
            let segment = convertJsonToTripSegment(segmentJson)
            tripSegments.append(segment)
          }
        }
      } else {
        if segmentsJson.isExists() {
          let segment = convertJsonToTripSegment(segmentsJson)
          if !(segment.type == .Walk && segment.distance! < 250) {
            tripSegments.append(segment)
          }
        }
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
    let dateTimeTuple = extractTimeDate(segmentJson)
    
    var rtuMessages: String? = nil
    if segmentJson["RTUMessages"].isExists() {
      rtuMessages = extractRtuMessages(segmentJson["RTUMessages"]["RTUMessage"])
    }
    
    var isWarning = DisturbanceTextHelper.isDisturbance(rtuMessages)
    let isReachable = (segmentJson["reachable"].string == nil) ? true : false
    let isCancelled = (segmentJson["cancelled"].string == nil) ? false : true
    if !isReachable || isCancelled {
      isWarning = true
    }
    
    return TripSegment(
      index: Int(segmentJson["idx"].string!)!,
      name: segmentJson["name"].string!,
      type: segmentJson["type"].string!,
      directionText: segmentJson["dir"].string, lineNumber: segmentJson["line"].string,
      origin: origin, destination: destination,
      departureTime: dateTimeTuple.depTime,
      arrivalTime: dateTimeTuple.arrTime,
      departureDate: dateTimeTuple.depDate,
      arrivalDate: dateTimeTuple.arrDate,
      distance: Int(distString), isRealtime: dateTimeTuple.isRealtime,
      journyRef: segmentJson["JourneyDetailRef"]["ref"].string,
      geometryRef: segmentJson["GeometryRef"]["ref"].string!,
      rtuMessages: rtuMessages, notes: "", isWarning: isWarning,
      isReachable: isReachable, isCancelled: isCancelled)
  }
  
  /**
   * Converts json to location object.
   */
  private static func convertJsonToLocation(locationJson: JSON) -> Location {
    let name = (locationJson["name"].string != nil) ? locationJson["name"].string! : ""
    return Location(
      id: locationJson["id"].string,
      name: ensureUTF8(name),
      type: locationJson["type"].string!,
      lat: locationJson["lat"].string!,
      lon: locationJson["lon"].string!)
  }
  
  
  /**
   * Ensures the string is UTF8
   */
  private static func ensureUTF8(string: String) -> String {
    var newString = string
    let data = newString.dataUsingEncoding(NSISOLatin1StringEncoding, allowLossyConversion: false)!
    let convertedName = NSString(data: data, encoding: NSUTF8StringEncoding)
    if let convName = convertedName {
      newString = convName as String
    }
    
    return newString
  }
  
  /**
   * Extracts departure date/time and arriaval date/time.
   * Uses realtime data if available.
   */
  private static func extractTimeDate(segment: JSON)
    -> (isRealtime: Bool, depDate: String, depTime: String, arrDate: String, arrTime: String) {
      
      var isRealtime = false
      var depDate = segment["Origin"]["date"].string!
      var depTime = segment["Origin"]["time"].string!
      var arrDate = segment["Destination"]["date"].string!
      var arrTime = segment["Destination"]["time"].string!
      
      if let rtDate = segment["Origin"]["rtDate"].string {
        isRealtime = true
        depDate = rtDate
      }
      if let rtTime = segment["Origin"]["rtTime"].string {
        isRealtime = true
        depTime = rtTime
      }
      
      if let rtDate = segment["Destination"]["rtDate"].string {
        isRealtime = true
        arrDate = rtDate
      }
      if let rtTime = segment["Destination"]["rtTime"].string {
        isRealtime = true
        arrTime = rtTime
      }
      
      return (isRealtime, depDate, depTime, arrDate, arrTime)
  }
  
  /**
   * Extract RTU Messages (trip warnings).
   */
  private static func extractRtuMessages(data: JSON) -> String {
    var result = ""
    if let messages = data.array {
      for mess in messages {
        result += mess["$"].string! + "\n\n"
      }
      result = result.substringToIndex(result.endIndex.predecessor().predecessor())
    } else {
      result = data["$"].string!
    }
    
    return result
  }
}