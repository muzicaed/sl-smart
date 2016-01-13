//
//  StringUtils.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-01-13.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation

class StringUtils {

  /**
   * Helper. Fixes broken UTF-8 encoding that sometimes
   * occur in the SL Api
   */
  static func fixBrokenEncoding(str: String) -> String {
    var fixedStr = str.stringByReplacingOccurrencesOfString("Ã¥", withString: "å")
    fixedStr = fixedStr.stringByReplacingOccurrencesOfString("Ã¤", withString: "ä")
    fixedStr = fixedStr.stringByReplacingOccurrencesOfString("Ã¶", withString: "ö")
    fixedStr = fixedStr.stringByReplacingOccurrencesOfString("Ã…", withString: "Å")
    fixedStr = fixedStr.stringByReplacingOccurrencesOfString("Ã„", withString: "Ä")
    fixedStr = fixedStr.stringByReplacingOccurrencesOfString("Ã–", withString: "Ö")
    return fixedStr
  }
}