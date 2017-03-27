//
//  LocalizedString.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2017-03-27.
//  Copyright © 2017 Mikael Hellman. All rights reserved.
//

import Foundation

extension String {
  var localized: String {
    return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
  }
}

extension String {
  var first: String {
    return String(characters.prefix(1))
  }
  var last: String {
    return String(characters.suffix(1))
  }
  var uppercaseFirst: String {
    return first.uppercased() + String(characters.dropFirst())
  }
}
