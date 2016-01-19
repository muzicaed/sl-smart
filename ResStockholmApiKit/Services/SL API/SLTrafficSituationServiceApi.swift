//
//  SLTrafficSituationServiceApi.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-12-10.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation

class SLTrafficSituationServiceApi {
  
  let apiKey = "3cbb0a4852e24020a58ef63a0399ac9b"
  let urlBase = "http://api.sl.se/api2/trafficsituation.json"
  
  /**
   * Search for traffic situations.
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