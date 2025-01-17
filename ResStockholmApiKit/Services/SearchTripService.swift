//
//  SearchTripService.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-23.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import CoreLocation

open class SearchTripService {
    
    fileprivate static let api = SLTravelPlannerV3Api()
    
    /**
     * Trip search.
     */
    public static func tripSearch(
        _ criterion: TripSearchCriterion,
        callback: @escaping ([Trip], SLNetworkError?) -> Void) {
        api.tripSearch(criterion) { resTuple in
            var trips = [Trip]()
            if let data = resTuple.0 {
                if data.count == 0 {
                    HttpRequestHelper.clearCache()
                    callback(trips, SLNetworkError.noDataFound)
                    return
                }
                trips = self.convertJsonResponse(data, criterion.copy() as! TripSearchCriterion)
            }
            callback(trips, resTuple.1)
        }
    }
    
    /**
     * Refresh trip data
     */
    public static func tripRefresh(
        _ criterion: TripSearchCriterion,
        tripsToRefresh: [Trip],
        callback: @escaping () -> Void) {
        
        tripSearch(criterion) { (trips, error) in
            var tripsDict = [String: Trip]()
            for trip in trips {
                tripsDict[trip.tripKey] = trip
            }
            
            for refreshTrip in tripsToRefresh {
                if let newTrip = tripsDict[refreshTrip.tripKey] {
                    refreshTrip.refresh(newTrip)
                }
            }
            callback()
        }
    }
    
    // MARK: Private methods
    
    /**
     * Converts the raw json string into array of Trip.
     */
    fileprivate static func convertJsonResponse(_ jsonDataString: Data, _ criterion: TripSearchCriterion) -> [Trip] {
        var result = [Trip]()
        let data = JSON(data: jsonDataString)
        if checkErrors(data) {
            return [Trip]()
        }
        
        if let tripsJson = data["Trip"].array {
            for tripJson in tripsJson {
                result.append(convertJsonToTrip(tripJson, criterion))
            }
        } else {
            result.append(convertJsonToTrip(data["TripList"]["Trip"], criterion))
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
    fileprivate static func convertJsonToTrip(_ tripJson: JSON, _ criterion: TripSearchCriterion) -> Trip {
        let tripSegments = convertJsonToSegments(tripJson["LegList"]["Leg"])
        var isValid = true
        if let val = tripJson["valid"].string {
            isValid = (val == "false") ? false : true
        }
        return Trip(
            durationText: tripJson["duration"].string!,
            noOfChanges: (tripJson["chg"].string != nil) ? Int(tripJson["chg"].string!)! : 0,
            isValid: isValid,
            tripSegments: tripSegments.sorted(by: { $0.index < $1.index }),
            criterion: criterion)
    }
    
    /**
     * Converts json to trip segment object.
     */
    fileprivate static func convertJsonToSegments(_ segmentsJson: JSON) -> [TripSegment] {
        var tripSegments = [TripSegment]()
        if let segmentsArr = segmentsJson.array  {
            for segmentJson in segmentsArr {
                if segmentJson["Origin"]["date"].string != nil {
                    let segment = convertJsonToTripSegment(segmentJson)
                    tripSegments.append(segment)
                }
            }
        } else {
            if segmentsJson["Origin"]["date"].string != nil {
                let segment = convertJsonToTripSegment(segmentsJson)
                if !(segment.type == .Walk && segment.distance! < 250) {
                    tripSegments.append(segment)
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
        
        let dist = (segmentJson["dist"].int != nil) ? segmentJson["dist"].int! : 0
        let dateTimeTuple = extractTimeDate(segmentJson)
        let messages = extractMessages(segmentJson["Messages"]["Message"])
        
        var isWarning = DisturbanceTextHelper.isDisturbance(messages)
        let isReachable = (segmentJson["reachable"].string == nil) ? true : false
        let isCancelled = (segmentJson["cancelled"].string == nil) ? false : true
        if !isReachable || isCancelled {
            isWarning = true
        }
        
        let geoRoute = extractGeoRoute(segmentJson)
        
        return TripSegment(
            index: Int(segmentJson["idx"].string!)!,
            name: segmentJson["name"].string!,
            type: extractTripType(segmentJson),
            directionText: segmentJson["direction"].string, lineNumber: segmentJson["Product"]["line"].string,
            origin: origin, destination: destination,
            departureTime: dateTimeTuple.depTime,
            arrivalTime: dateTimeTuple.arrTime,
            departureDate: dateTimeTuple.depDate,
            arrivalDate: dateTimeTuple.arrDate,
            distance: dist, isRealtime: dateTimeTuple.isRealtime,
            journyRef: segmentJson["JourneyDetailRef"]["ref"].string,            
            messages: messages, notes: "", isWarning: isWarning,
            isReachable: isReachable, isCancelled: isCancelled, geoRoute: geoRoute)
    }
    
    /**
     * Converts json to location object.
     */
    fileprivate static func convertJsonToLocation(_ locationJson: JSON) -> Location {
        return Location(
            id: locationJson["extId"].string,
            name: locationJson["name"].string,
            type: locationJson["type"].string,
            lat: locationJson["lat"].double,
            lon: locationJson["lon"].double)
    }
    
    /**
     * Extracts departure date/time and arriaval date/time.
     * Uses realtime data if available.
     */
    fileprivate static func extractTimeDate(_ segment: JSON)
        -> (isRealtime: Bool, depDate: String, depTime: String, arrDate: String, arrTime: String) {
            
            var isRealtime = false
            // TODO: Crash here!!!
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
     * Extract TripType from JSON.
     */
    fileprivate static func extractTripType(_ data: JSON) -> TripType {
        if let type = data["type"].string {
            if type == "JNY" {
                return TripType.fromCode(code: data["Product"]["catCode"].string!)
            }
        }
        
        return TripType.Walk
    }
    
    /**
     * Extract Messages (trip warnings).
     */
    fileprivate static func extractMessages(_ data: JSON) -> String? {
        if let messages = data.array {
            var result = ""
            for mess in messages {
                result += mess["text"].string!
                result += (mess == messages.last) ? "\n" : ""
            }
            return result
        }
        
        return nil
    }
    
    /**
     * Extract route (coords for map route).
     */
    fileprivate static func extractGeoRoute(_ data: JSON) -> [CLLocationCoordinate2D] {
        var locations = [CLLocationCoordinate2D]()
        if let coordData = data["Polyline"]["crd"].array {
            if(coordData.count > 2) {
                locations = extractLocations(coordData)
            }
        }
        return locations
    }
    
    /**
     * Extract locations for map route.
     */
    fileprivate static func extractLocations(_ coords: [JSON]) -> [CLLocationCoordinate2D] {
        var locations = [CLLocationCoordinate2D]()
        var prevLonInt = coords[0].int!
        var prevlatInt = coords[1].int!
        let startLocation = mantissaToLocation(lonInt: prevLonInt, latInt: prevlatInt)
        locations.append(startLocation)
        
        let coordPairs = stride(from: 2, to: coords.count, by: 2).map {
            (lon: coords[$0].int!, lat: coords[$0.advanced(by: 1)].int!)
        }
        
        for coordDelta in coordPairs {
            let newLonInt = prevLonInt + coordDelta.lon
            let newLatInt = prevlatInt + coordDelta.lat
            locations.append(
                mantissaToLocation(
                    lonInt: newLonInt,
                    latInt: newLatInt
                )
            )
            prevLonInt = newLonInt
            prevlatInt = newLatInt
        }
        
        return locations
    }
    
    /**
     * Extract locations for map route.
     */
    fileprivate static func mantissaToLocation(lonInt: Int, latInt: Int) -> CLLocationCoordinate2D {
        let lon = NSDecimalNumber(mantissa: UInt64(lonInt), exponent: -6, isNegative: false)
        let lat = NSDecimalNumber(mantissa: UInt64(latInt), exponent: -6, isNegative: false)
        return CLLocationCoordinate2D(latitude: lat.doubleValue, longitude: lon.doubleValue)
    }
}
