//
//  SLSearchStationApi.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-22.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation

class SLSearchStationApi {
  
  let apiKey = "d6ab40d679d8426095c5da373c6aa1da"
  let urlBase = "http://api.sl.se/api2/typeahead.json"
  
  /**
   * Search for station.
   */
  func search(query: String, callback: (NSData) -> Void) {
    let url = createApiUrl(query)
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
   * Creates api url
   */
  private func createApiUrl(query: String) -> String {
    if let escapedQuery = query.stringByAddingPercentEncodingWithAllowedCharacters(
      .URLHostAllowedCharacterSet()) {
        return urlBase + "?key=\(apiKey)&searchstring=\(escapedQuery)"
    }
    
    fatalError("Could not encode query string.")
  }
}