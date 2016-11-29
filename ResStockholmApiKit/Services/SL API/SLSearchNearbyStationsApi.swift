//
//  SLSearchNearbyStationsApi.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-27.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import CoreLocation

class SLSearchNearbyStationsApi {
  
  let apiKey = "2f39d929d2394fd996e4e907fcb2be14"
  let urlBase = "http://api.sl.se/api2/nearbystops.json"
  
  /**
   * Search for nearby stations.
   */
  func search(
    _ position: CLLocation, distance: Int,
    callback: @escaping ((data: Data?, error: SLNetworkError?)) -> Void) {
      let url = createApiUrl(position, distance: distance)
      HttpRequestHelper.makeGetRequest(url) { resTuple in
        callback(resTuple)
      }
  }
  
  // MARK: Private methods.
  
  /**
  * Creates api url for nearby station search
  */
  fileprivate func createApiUrl(_ position: CLLocation, distance: Int) -> String {
    var url = urlBase + "?key=\(apiKey)"
    url += "&originCoordLat=\(position.coordinate.latitude)"
    url += "&originCoordLong=\(position.coordinate.longitude)"
    url += "&radius=\(distance)&maxResults=\(50)"
    return url
  }
  
}
