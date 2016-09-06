//
//  StaticSite.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-09-06.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation

public class StaticSite {
  
  public let siteId: Int
  public let siteName: String
  public let stopAreaNumber: Int
  
  /**
   * Standard init
   */
  public init(siteId: Int, siteName: String, stopAreaNumber: Int) {
    self.siteId = siteId
    self.siteName = siteName
    self.stopAreaNumber = stopAreaNumber
  }
}