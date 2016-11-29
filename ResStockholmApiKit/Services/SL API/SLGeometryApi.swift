//
//  SLGeometryApi.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-01-16.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation

class SLGeometryApi {
  
  let apiKey = "e785e23627434ac295f09e08053147dc"
  let urlBase = "http://api.sl.se/api2/TravelplannerV2/geometry.json"
  
  /**
   * Fetch geometry data for a trip
   */
  func fetchGeometry(
    _ urlEncRef: String,
    callback: @escaping ((data: Data?, error: SLNetworkError?)) -> Void) {
      let url = createGeometryUrl(urlEncRef)
      HttpRequestHelper.makeGetRequest(url) { resTuple in
        callback(resTuple)
      }
  }
  
  // MARK: Private methods.
  
  /**
  * Creates api url for geometry search
  */
  fileprivate func createGeometryUrl(_ urlEncRef: String) -> String {
    let decoded = urlEncRef.stringByRemovingPercentEncoding!
    return urlBase + "?key=\(apiKey)&\(decoded)"
  }
}
