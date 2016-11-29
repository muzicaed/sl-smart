//
//  SearchTripService.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-23.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation

open class SearchTripService {
  
  fileprivate static let api = SLTravelPlannerV2Api()
  
  /**
   * Trip search.
   */
  open static func tripSearch(
    _ criterion: TripSearchCriterion,
    callback: @escaping (_ data: [Trip], _ error: SLNetworkError?) -> Void) {
    api.tripSearch(criterion) { resTuple in
      var trips = [Trip]()
      if let data = resTuple.data {
        if data.count == 0 {
          HttpRequestHelper.clearCache()
          callback(data: trips, error: SLNetworkError.noDataFound)          
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
  fileprivate static func convertJsonResponse(_ jsonDataString: Data) -> [Trip] {
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
  fileprivate static func checkErrors(_ data: JSON) -> Bool {
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
  fileprivate static func convertJsonToTrip(_ tripJson: JSON) -> Trip {
    let tripSegments = convertJsonToSegments(tripJson["LegList"]["Leg"])
    var isValid = true
    if let val = tripJson["valid"].string {
      isValid = (val == "false") ? false : true
    }
    return Trip(
      durationMin: Int(tripJson["dur"].string!)!,
      noOfChanges: Int(tripJson["chg"].string!)!,
      isValid: isValid,
      tripSegments: tripSegments.sorted(by: { $0.index < $1.index }))
  }
  
  /**
   * Converts json to trip segment object.
   */
  fileprivate static func convertJsonToSegments(_ segmentsJson: JSON) -> [TripSegment] {
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
  fileprivate static func convertJsonToTripSegment(_ segmentJson: JSON) -> TripSegment {
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
      rtuMessages: rtuMessages, notes: "", isWarning: isWarning,
      isReachable: isReachable, isCancelled: isCancelled)
  }
  
  /**
   * Converts json to location object.
   */
  fileprivate static func convertJsonToLocation(_ locationJson: JSON) -> Location {
    return Location(
      id: locationJson["id"].string,
      name: locationJson["name"].string,
      type: locationJson["type"].string,
      lat: locationJson["lat"].string!,
      lon: locationJson["lon"].string!)
  }
  
  

  
  /**
   * Extracts departure date/time and arriaval date/time.
   * Uses realtime data if available.
   */
  fileprivate static func extractTimeDate(_ segment: JSON)
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
  fileprivate static func extractRtuMessages(_ data: JSON) -> String {
    var result = ""
    if let messages = data.array {
      for mess in messages {
        result += mess["$"].string! + "\n\n"
      }
      result = result.substring(to: <#T##Collection corresponding to your index##Collection#>.index(before: result.characters.index(before: result.endIndex)))
    } else {
      result = data["$"].string!
    }
    
    return result
  }
}
