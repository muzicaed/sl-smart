//
//  Instruction.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2017-02-13.
//  Copyright © 2017 Mikael Hellman. All rights reserved.
//

import Foundation
import ResStockholmApiKit

class Instruction {
  
  let segment: TripSegment
  let type: InstructionType
  let index: Int
  
  init(segment: TripSegment, type: InstructionType, index: Int) {
    self.segment = segment
    self.type = type
    self.index = index
  }
}
