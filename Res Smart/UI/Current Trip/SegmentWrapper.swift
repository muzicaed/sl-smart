//
//  SegmentWrapper.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2017-02-13.
//  Copyright © 2017 Mikael Hellman. All rights reserved.
//

import Foundation
import ResStockholmApiKit

class SegmentWrapper {
  
  let segment: TripSegment
  var hasPassed = false
  var hitCount = 0
  var prev: SegmentWrapper?
  var next: SegmentWrapper?
  
  init (_ segment: TripSegment) {
    self.segment = segment
  }
}
