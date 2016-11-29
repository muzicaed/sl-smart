//
//  SLRealtimeDepartures.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-01-19.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation

class SLRealtimeDepartures {
  
  let apiKey = "eabf4986caee4072a96fa6d5ec860e5c"
  let urlBase = "http://api.sl.se/api2/realtimedepartures.json"
  
  /**
   * Search for real time.
   */
  func getRealTimeTable(
    _ siteId: Int,
    callback: @escaping ((data: Data?, error: SLNetworkError?)) -> Void) {
      let url = createRealTimeSearchUrl(siteId)
      HttpRequestHelper.makeGetRequest(url) { resTuple in
        callback(resTuple)
      }
  }
  
  // MARK: Private methods.
  
  /**
  * Creates api url for real time search
  */
  fileprivate func createRealTimeSearchUrl(_ siteId: Int) -> String {
    return urlBase + "?key=\(apiKey)&SiteId=\(siteId)&TimeWindow=60"
  }
}
