//
//  SLNetworkError.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-12-06.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation

public enum SLNetworkError: ErrorType {
  case ServiceUnavailable
  case NetworkError
  case NoDataFound
  case InvalidRequest
}
