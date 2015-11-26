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
  
  /**
   * Search for trips.
   */
  func tripSearch(criterions: TripSearchCriterion, callback: (NSData) -> Void) {
    let url = createSimpleSearchApiUrl(criterions)
    HttpRequestHelper.makeGetRequest(url) { response in
      if let data = response {
        callback(data)
      } else {
        // TODO: Better error
        fatalError("No data in response")
      }
    }
  }
  
  // MARK: Private methods.
  
  /**
  * Creates api url for simple search
  */
  private func createSimpleSearchApiUrl(criterions: TripSearchCriterion) -> String {
    let criterionsUrl = criterions.generateQueryString(false)    
    return urlBase + "?key=\(apiKey)\(criterionsUrl)"
  }
}
