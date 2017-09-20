//
//  HttpRequestHelper.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-22.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation

class HttpRequestHelper {
  
  fileprivate static var cache = [String: (data: Data, date: Date)]()
  fileprivate static var lastKey: String? = nil
  
  /**
   * Makes a async get request to passed url.
   * Returns the response data using callback.
   */
  static func makeGetRequest(
    _ url: String, callback: @escaping ((data: Data?, error: SLNetworkError?)) -> Void) {
    
    let urlconfig = URLSessionConfiguration.default
    urlconfig.timeoutIntervalForRequest = 10
    urlconfig.timeoutIntervalForResource = 10
    
    if let cacheData = handleCache(url) {
      //print("CACHE: \(url)")
      //print("")
      callback((cacheData, nil))
      return
    }
    //print(url)
    //print("")
    
    if let nsUrl = URL(string: url) {
      let request = URLRequest(url: nsUrl)
      let session = URLSession(configuration: urlconfig)
      let task = session.dataTask(with: request, completionHandler: {
        data, response, error in
        if error != nil {
          callback((data: nil, error: SLNetworkError.networkError))
          return
        } else if data != nil {
          addDataToCache(url, data: data!)
          callback((data: data, error: nil))
          return
        }
        callback((data: nil, error: SLNetworkError.noDataFound))
        return
      }) 
      
      task.resume()
      return
    }
    callback((data: nil, error: SLNetworkError.invalidRequest))
  }
  
  /**
   * Clears the last http response cache.
   */
  static func clearCache() {
    if let key = lastKey {
      cache[key] = nil
    }    
  }
  
  // MARK: Private
  
  /**
   * Handle cache lookup
   */
  fileprivate static func handleCache(_ url: String) -> Data? {
    if let dataTuple = cache[url] {
      if Date().timeIntervalSince(dataTuple.date) < cacheTolerance(url) {
        return dataTuple.data
      }
    }
    return nil
  }
  
  /**
   * Add data to cache
   */
  fileprivate static func addDataToCache(_ url: String, data: Data) {
    lastKey = url
    cache[url] = (data, Date())
  }
  
  /**
   * The maximum time (in seconds) to store cache
   */
  fileprivate static func cacheTolerance(_ url: String) -> TimeInterval {
    if url.lowercased().range(of: "journeydetail.json") != nil ||
      url.lowercased().range(of: "geometry.json") != nil {
      return (60 * 60 * 18) // 18 hours
    } else if url.lowercased().range(of: "realtimedepartures.json") != nil {
      return 30 // 30 seconds
    } else if url.lowercased().range(of: "trafficsituation.json") != nil {
      return (60 * 10) // 10 minutes
    }
    
    return 5
  }
}
