//
//  DisturbanceTextHelper.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-01-26.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation

public class DisturbanceTextHelper {
  
  public class func isDisturbance(text: String?) -> Bool {
    if let text = text {
      return (text.lowercaseString.rangeOfString("försen") != nil ||
        text.lowercaseString.rangeOfString("utebli") != nil ||
        text.lowercaseString.rangeOfString("signalfel") != nil ||
        text.lowercaseString.rangeOfString("inställd") != nil ||        
        text.lowercaseString.rangeOfString("stannar inte") != nil ||
        text.lowercaseString.rangeOfString("banarbete") != nil ||        
        text.lowercaseString.rangeOfString("stannar ej") != nil)
    }
    
    return false
  }
}