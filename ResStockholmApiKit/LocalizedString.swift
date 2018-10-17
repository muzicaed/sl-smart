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
