//
//  HttpRequestHelper.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-22.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import SwiftHTTP

class HttpRequestHelper {
  
  /**
   * Makes a async get request to passed url.
   * Returns the response data using callback.
   */
  static func makeGetRequest(url: String,
    callback: ((data: NSData?, error: SLNetworkError?)) -> Void) {
      //print("GET: \(url)")
      let operationQueue = NSOperationQueue()
      operationQueue.maxConcurrentOperationCount = 4
      
      do {
        let opt = try HTTP.New(url, method: .GET)
        opt.onFinish = { response in
          if response.error != nil {
            callback((nil, SLNetworkError.NetworkError))
          }
          
          callback((response.data, nil))
        }
        operationQueue.addOperation(opt)
      } catch _ {
        callback((nil, SLNetworkError.InvalidRequest))
      }
  }
}