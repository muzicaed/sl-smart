//
//  PickGenericValueResponder.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-05-03.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation


protocol PickGenericValueResponder {
  
  func pickedValue(_ type: GenericValuePickerVC.ValueType, value: Int)
}
