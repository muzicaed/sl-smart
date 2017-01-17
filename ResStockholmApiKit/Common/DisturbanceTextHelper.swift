//
//  DisturbanceTextHelper.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-01-26.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation

open class DisturbanceTextHelper {
  
  open class func isDisturbance(_ text: String?) -> Bool {
    if let text = text {
      return (text.lowercased().range(of: "försen") != nil ||
        text.lowercased().range(of: "utebli") != nil ||
        text.lowercased().range(of: "signalfel") != nil ||
        text.lowercased().range(of: "inställd") != nil ||        
        text.lowercased().range(of: "stannar inte") != nil ||
        text.lowercased().range(of: "banarbete") != nil ||
        text.lowercased().range(of: "rökutveckling") != nil ||
        text.lowercased().range(of: "växelfel") != nil ||
        text.lowercased().range(of: "stannar ej") != nil)            
    }
    
    return false
  }
}
