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
  
  static func makeGetRequest(url: String, callback: (NSData?) -> Void) {
    print("GET: \(url)")
    let operationQueue = NSOperationQueue()
    operationQueue.maxConcurrentOperationCount = 4
    do {
      let opt = try HTTP.New(url, method: .GET)
      opt.onFinish = { response in
        if let error = response.error {
          // TODO: Better error handeling here...
          fatalError("Got an error: \(error)")
        }
        callback(response.data)
      }
      operationQueue.addOperation(opt)
    } catch let error {
      fatalError("Got an error creating the request: \(error)")
    }
  }
}