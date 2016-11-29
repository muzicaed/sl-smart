//
//  GeometryService.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-01-16.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation
import CoreLocation

open class GeometryService {
  
  fileprivate static let api = SLGeometryApi()
  
  /**
   * Fetch geometry data
   */
  open static func fetchGeometry(_ urlEncRef: String,
                                 callback: @escaping (_ data: [CLLocation], _ error: SLNetworkError?) -> Void) {
    var result = [CLLocation]()
    api.fetchGeometry(urlEncRef) { (data, error) -> Void in
      if let d = data {
        if d.count == 0 {
          HttpRequestHelper.clearCache()
          callback([CLLocation](), SLNetworkError.noDataFound)
          return
        }
        
        let jsonData = JSON(data: d)
        result = convertJson(jsonData["Geometry"]["Points"]["Point"])
      }
      callback(result, error)
    }
  }
  
  // MARK: Private
  
  /**
   * Converts the raw json string into array of Location.
   */
  fileprivate static func convertJson(_ pointsJson: JSON) -> [CLLocation] {
    var result = [CLLocation]()
    if let pointsArr = pointsJson.array  {
      for pointJson in pointsArr {
        if pointJson["lat"].string! != "" && pointJson["lon"].string! != "" {
          let location = CLLocation(
            latitude: Double(pointJson["lat"].string!)!,
            longitude: Double(pointJson["lon"].string!)!)
          result.append(location)
        }
      }      
    }
    return result
  }
  
}
