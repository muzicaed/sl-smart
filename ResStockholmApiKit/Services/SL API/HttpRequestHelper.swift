//
//  HttpRequestHelper.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-22.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation

class HttpRequestHelper {
  
  private static var cache = [String: (data: NSData, date: NSDate)]()
  
  /**
   * Makes a async get request to passed url.
   * Returns the response data using callback.
   */
  static func makeGetRequest(
    url: String, callback: ((data: NSData?, error: SLNetworkError?)) -> Void) {
    
    print(url)
    
    if let cacheData = handleCache(url) {
      callback((cacheData, nil))
      return
    }
    
    if let nsUrl = NSURL(string: url) {
      let request = NSMutableURLRequest(URL: nsUrl)
      let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
        data, response, error in
        if error != nil {
          callback((nil, error: SLNetworkError.NetworkError))
          return
        } else if data != nil {
          addDataToCache(url, data: data!)
          callback((data, error: nil))
          return
        }
        callback((nil, error: SLNetworkError.NoDataFound))
        return
      }
      
      task.resume()
      return
    }
    callback((nil, error: SLNetworkError.InvalidRequest))
  }
  
  // MARK: Private
  
  /**
   * Handle cache lookup
   */
  private static func handleCache(url: String) -> NSData? {
    if let dataTuple = cache[url] {
      if NSDate().timeIntervalSinceDate(dataTuple.date) < cacheTolerance(url) {
        return dataTuple.data
      }
    }
    return nil
  }
  
  /**
   * Add data to cache
   */
  private static func addDataToCache(url: String, data: NSData) {
    cache[url] = (data, NSDate())
  }
  
  /**
   * The maximum time (in seconds) to store cache
   */
  private static func cacheTolerance(url: String) -> NSTimeInterval {
    if url.lowercaseString.rangeOfString("journeydetail.json") != nil ||
      url.lowercaseString.rangeOfString("geometry.json") != nil {
      return (60 * 60 * 18) // 18 hours
    } else if url.lowercaseString.rangeOfString("realtimedepartures.json") != nil {
      return 30 // 30 seconds
    } else if url.lowercaseString.rangeOfString("trafficsituation.json") != nil {
      return (60 * 10) // 10 minutes
    }
    
    return 60 // 1 minute
  }
}