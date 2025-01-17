//
//  SLSearchLocationApi.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-22.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation

class SLSearchLocationApi {
    
    let apiKey = "d6ab40d679d8426095c5da373c6aa1da"
    let urlBase = "http://api.sl.se/api2/typeahead.json"
    
    /**
     * Search for location.
     */
    func search(
        _ query: String, stationsOnly: Bool,
        callback: @escaping ((data: Data?, error: SLNetworkError?)) -> Void) {
        let url = createApiUrl(query, stationsOnly: stationsOnly)
        HttpRequestHelper.makeGetRequest(url) { resTuple in
            callback(resTuple)
        }
    }
    
    // MARK: Private methods.
    
    /**
     * Creates api url
     */
    fileprivate func createApiUrl(_ query: String, stationsOnly: Bool) -> String {
        if let escapedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            return urlBase + "?Key=\(apiKey)&MaxResults=50&StationsOnly=\(stationsOnly)&SearchString=\(escapedQuery)"
        }
        
        fatalError("Could not encode query string.")
    }
}
