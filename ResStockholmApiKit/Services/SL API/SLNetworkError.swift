//
//  SLNetworkError.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-12-06.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation

public enum SLNetworkError: Error {
  case serviceUnavailable
  case networkError
  case noDataFound
  case invalidRequest
}
