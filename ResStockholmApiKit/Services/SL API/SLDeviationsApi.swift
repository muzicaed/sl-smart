//
//  SLDeviationsApi.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-02-22.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation

class SLDeviationsApi {
  
  let apiKey = "55ca4dbb5fdb48788fab96e8e4bd4bba"
  let urlBase = "http://api.sl.se/api2/deviations.json"
  
  /**
   * Search for deviations.
   */
  func fetchInformation(_ callback: @escaping ((data: Data?, error: SLNetworkError?)) -> Void) {
    HttpRequestHelper.makeGetRequest(createApiUrl()) { resTuple in
      callback(resTuple)
    }
  }
  
  /**
   * Creates api url
   */
  fileprivate func createApiUrl() -> String {
    return urlBase + "?Key=\(apiKey)"
  }
}
