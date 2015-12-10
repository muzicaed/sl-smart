//
//  SLTrafficSituationServiceApi.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-12-10.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation

class SLTrafficSituationServiceApi {
  
  let apiKey = "55ca4dbb5fdb48788fab96e8e4bd4bba"
  let urlBase = "http://api.sl.se/api2/trafficsituation.json"
  
  /**
   * Search for location.
   */
  func fetchInformation(callback: ((data: NSData?, error: SLNetworkError?)) -> Void) {
      HttpRequestHelper.makeGetRequest(createApiUrl()) { resTuple in
        callback(resTuple)
      }
  }
  
  /**
   * Creates api url
   */
  private func createApiUrl() -> String {
    return urlBase + "?Key=\(apiKey)"
  }
}