//
//  LinePickerResponder.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-05-08.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation

protocol LinePickerResponder {
  
  func pickedLines(included: String?, excluded: String?)
}