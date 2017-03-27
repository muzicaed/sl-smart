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
  func tripSearch(
    _ criterions: TripSearchCriterion,
    callback: @escaping ((data: Data?, error: SLNetworkError?)) -> Void) {
      let url = createSimpleSearchApiUrl(criterions)
      HttpRequestHelper.makeGetRequest(url) { resTuple in
        callback(resTuple)        
      }
  }
  
  // MARK: Private methods.
  
  /**
  * Creates api url for simple search
  */
  fileprivate func createSimpleSearchApiUrl(_ criterions: TripSearchCriterion) -> String {    
    let criterionsUrl = criterions.generateQueryString(false)
    return urlBase + "?key=\(apiKey)\(criterionsUrl)&lang=\(LanguangeHelper.getLangCode())"
  }
}
