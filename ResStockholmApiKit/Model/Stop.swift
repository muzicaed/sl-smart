//
//  Stop.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-01-15.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation

public class Stop {
  public let id: String
  public let name: String
  public var depDate: NSDate?
  
  init(id: String, name: String, depDate: String?, depTime: String?) {
    self.id = id
    self.name = name
    
    if let date = depDate, time = depTime {
      self.depDate = DateUtils.convertDateString("\(date) \(time)")
    }
  }
}