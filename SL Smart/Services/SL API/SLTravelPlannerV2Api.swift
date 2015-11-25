//
//  SLTravelPlannerV2Api.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-23.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation

class SLTravelPlannerV2Api {
  
  let apiKey = "e785e23627434ac295f09e08053147dc"
  let urlBase = "http://api.sl.se/api2/TravelplannerV2/trip.json"
  
  func simpleSearch(origin: Station, destination: Station, callback: (NSData) -> Void) {
    let url = createSimpleSearchApiUrl(origin, destination: destination)
    HttpRequestHelper.makeGetRequest(url) { response in
      if let data = response {
        callback(data)
      } else {
        // TODO: Better error
        fatalError("No data in response")
      }
    }
  }
  
  /**
   * Creates api url for simple search
   */
  private func createSimpleSearchApiUrl(origin: Station, destination: Station) -> String {
    let time =  Utils.dateAsTimeString(NSDate())
    if let escapedTime = time.stringByAddingPercentEncodingWithAllowedCharacters(
      .URLHostAllowedCharacterSet()) {
        return urlBase + "?key=\(apiKey)&realtime=true&numTrips=1&time=\(escapedTime)&originId=\(origin.siteId)&destId=\(destination.siteId)"
    }
    fatalError("Could not encode time string.")
  }
}
