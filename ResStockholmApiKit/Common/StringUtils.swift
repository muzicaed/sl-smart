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
  static func fixBrokenEncoding(_ str: String) -> String {
    var fixedStr = str.replacingOccurrences(of: "Ã¥", with: "å")
    fixedStr = fixedStr.replacingOccurrences(of: "Ã¤", with: "ä")
    fixedStr = fixedStr.replacingOccurrences(of: "Ã¶", with: "ö")
    fixedStr = fixedStr.replacingOccurrences(of: "Ã…", with: "Å")
    fixedStr = fixedStr.replacingOccurrences(of: "Ã„", with: "Ä")
    fixedStr = fixedStr.replacingOccurrences(of: "Ã–", with: "Ö")
    return fixedStr
  }
}
