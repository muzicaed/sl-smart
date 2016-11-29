//
//  SLJourneyDetailsApi.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-01-15.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation

class SLJourneyDetailsApi {
  
  let apiKey = "e785e23627434ac295f09e08053147dc"
  let urlBase = "http://api.sl.se/api2/TravelplannerV2/journeydetail.json"
  
  /**
   * Search for journy details.
   */
  func getDetails(
    _ urlEncRef: String,
    callback: @escaping ((data: Data?, error: SLNetworkError?)) -> Void) {
      let url = createJournyDetailsUrl(urlEncRef)
      HttpRequestHelper.makeGetRequest(url) { resTuple in
        callback(resTuple)
      }
  }
  
  // MARK: Private methods.
  
  /**
  * Creates api url for journy details search
  */
  fileprivate func createJournyDetailsUrl(_ urlEncRef: String) -> String {
    let decoded = urlEncRef.stringByRemovingPercentEncoding!
    return urlBase + "?key=\(apiKey)&realtime=true&\(decoded)"
  }
}
