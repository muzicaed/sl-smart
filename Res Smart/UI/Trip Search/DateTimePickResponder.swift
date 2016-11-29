//
//  DateTimePickResponder.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-12-09.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation

protocol DateTimePickResponder {
  
  func pickedDate(_ date: Date?) -> Void
}
