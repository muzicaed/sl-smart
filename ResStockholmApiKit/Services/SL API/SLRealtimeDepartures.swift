//
//  SLRealtimeDepartures.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-01-19.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation

class SLRealtimeDepartures {
  
  //TODO: Remove old
  let apiKey = "8350ec2932794e1daf81abf225022ab3"
  let urlBase = "http://api.sl.se/api2/realtimedeparturesV4.json"
  
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
