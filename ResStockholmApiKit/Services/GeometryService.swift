//
//  GeometryService.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-01-16.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation
import CoreLocation

public class GeometryService {
  
  private static let api = SLGeometryApi()
  
  /**
   * Fetch geometry data
   */
  public static func fetchGeometry(urlEncRef: String,
    callback: (data: [CLLocation], error: SLNetworkError?) -> Void) {
      var result = [CLLocation]()
      api.fetchGeometry(urlEncRef) { (data, error) -> Void in
        if let d = data {
          if d.length == 0 {
            HttpRequestHelper.clearCache()
            callback(data: [CLLocation](), error: SLNetworkError.NoDataFound)
            return
          }
          
          let jsonData = JSON(data: d)
          result = convertJson(jsonData["Geometry"]["Points"]["Point"])
        }
        callback(data: result, error: error)
      }
  }
  
  // MARK: Private
  
  /**
  * Converts the raw json string into array of Location.
  */
  private static func convertJson(pointsJson: JSON) -> [CLLocation] {
    var result = [CLLocation]()
    if let pointsArr = pointsJson.array  {
      for pointJson in pointsArr {
        if pointJson.isExists() {
          if pointJson["lat"].string! != "" && pointJson["lon"].string! != "" {
            let location = CLLocation(
              latitude: Double(pointJson["lat"].string!)!,
              longitude: Double(pointJson["lon"].string!)!)
            result.append(location)
          }
        }
      }
    }
    return result
  }
  
}
