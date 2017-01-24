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

  let first: TripSegment
  let next: TripSegment?
  let instruction: InstructionType
  
  init(_ first: TripSegment, _ next: TripSegment?, _ instruction: InstructionType) {
    self.first = first
    self.next = next
    self.instruction = instruction
  }
}
