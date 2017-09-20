//
//  SLTravelPlannerV2Api.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-23.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation

class RRTravelPlannerV2Api {
  
  let apiKey = "d55a963e-fb23-4202-b57d-fea372ec5f54"
  let urlBase = "https://api.resrobot.se/v2/trip"
  
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
    //let criterionsUrl = criterions.generateQueryString()
    //return urlBase + "?key=\(apiKey)\(criterionsUrl)&lang=\(LanguangeHelper.getLangCode())&format=json"
    return ""
  }
}

