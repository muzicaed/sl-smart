//
//  CurrentTripResult.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2017-01-24.
//  Copyright © 2017 Mikael Hellman. All rights reserved.
//

import Foundation
import ResStockholmApiKit

class CurrentTripResult {

  let segment: TripSegment
  let instruction: InstructionType
  let index: Int
  
  init(_ index: Int, _ segment: TripSegment, _ instruction: InstructionType) {
    self.segment = segment
    self.instruction = instruction
    self.index = index
  }
}
