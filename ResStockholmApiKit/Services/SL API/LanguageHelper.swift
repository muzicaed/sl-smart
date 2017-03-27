//
//  LanguageHelper.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2017-03-27.
//  Copyright © 2017 Mikael Hellman. All rights reserved.
//

import Foundation

class LanguangeHelper {

  static func getLangCode() -> String {
    if let code = Locale.current.languageCode {
      if code == "sv" {
        return code
      }
    }
    return "en"
  }
}

