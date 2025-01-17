//
//  LocationSearchService.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-22.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import CoreLocation

public class LocationSearchService {
    
    fileprivate static let api = SLSearchLocationApi()
    fileprivate static let nearbyApi = SLSearchNearbyStationsApi()
    
    /**
     * Searches for locations based on the query
     */
    public static func search(
        _ query: String, stationsOnly: Bool,
        callback: @escaping (_ data: [Location], _ error: SLNetworkError?) -> Void) {
        api.search(query, stationsOnly: stationsOnly) { resTuple in
            var locations = [Location]()
            if let data = resTuple.0 {
                locations = LocationSearchService.convertJsonResponse(data)
                if locations.count == 0 {
                    HttpRequestHelper.clearCache()
                    callback(locations, SLNetworkError.noDataFound)
                    return
                }
            }
            callback(locations, resTuple.1)
        }
    }
    
    /**
     * Searches for nearby locations.
     */
    public static func searchNearby(
        _ location: CLLocation, distance: Int,
        callback: @escaping (_ data: [(location: Location, dist: Int)], _ error: SLNetworkError?) -> Void) {
        
        nearbyApi.search(location, distance: distance) { resTuple in
            var result = [(location: Location, dist: Int)]()
            if let resData = resTuple.0 {
                let data = JSON(data: resData)
                
                if let locationJson = data["LocationList"]["StopLocation"].array {
                    for locationJson in locationJson {
                        let id = locationJson["id"].string!.replacingOccurrences(of: "30010", with: "")
                        let location = Location(
                            id: id, name: locationJson["name"].string!, type: "ST",
                            lat: convertCoordinateFormat(locationJson["lat"].string!),
                            lon: convertCoordinateFormat(locationJson["lon"].string!))
                        
                        let res = (location: location, dist: Int(locationJson["dist"].string!)!)
                        result.append(res)
                    }
                } else if let locationJson = data["LocationList"]["StopLocation"].object as? JSON {
                    let id = locationJson["id"].string!.replacingOccurrences(of: "30010", with: "")
                    let location = Location(
                        id: id, name: locationJson["name"].string!, type: "ST",
                        lat: convertCoordinateFormat(locationJson["lat"].string!),
                        lon: convertCoordinateFormat(locationJson["lon"].string!))
                    
                    let res = (location: location, dist: Int(locationJson["dist"].string!)!)
                    result.append(res)
                }
            }
            
            if result.count == 0 {
                callback(result, SLNetworkError.noDataFound)
                return
            }
            callback(result, resTuple.1)
        }
    }
    
    /**
     * Converts the raw json string into array of Location.
     */
    fileprivate static func convertJsonResponse(_ jsonData: Data) -> [Location] {
        var result = [Location]()
        let data = JSON(data: jsonData)
        
        for (_,locationJson):(String, JSON) in data["ResponseData"] {
            if !isCodeLocation(locationJson) {
                let location = Location(
                    id: locationJson["SiteId"].string!,
                    name: locationJson["Name"].string!,
                    type: locationJson["Type"].string!,
                    lat: convertCoordinateFormat(locationJson["Y"].string!),
                    lon: convertCoordinateFormat(locationJson["X"].string!)
                )
                result.append(location)
            }
            if result.count > 15 {
                break
            }
        }
        
        return result
    }
    
    /**
     * Check if location is "code location" eg. SPA, TERT
     */
    fileprivate static func isCodeLocation(_ locationJson: JSON) -> Bool {
        let name = locationJson["Name"].string!
        if name == name.uppercased() && name.count < 5 {
            return true
        }
        return false
    }
    
    /**
     * Converts Xpos & Ypos returned from SL Services
     * into true lat/lon values
     */
    fileprivate static func convertCoordinateFormat(_ coordinate: String) -> Double {
        if !coordinate.contains(".") {
            let index = 2
            let stringCoord = String(coordinate.prefix(index)) +
                "." + String(coordinate.suffix(coordinate.count - index))
            return Double(stringCoord)!
        }
        return 0.0
    }
}
