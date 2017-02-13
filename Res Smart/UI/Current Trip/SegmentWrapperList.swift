//
//  SegmentWrapperList.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2017-02-13.
//  Copyright © 2017 Mikael Hellman. All rights reserved.
//

import Foundation

class SegmentWrapperList {

  var first: SegmentWrapper?
  var last: SegmentWrapper?

  func append(_ segment: SegmentWrapper) {
    if first == nil {
      first = segment
      last = segment
      return
    }
    
    segment.prev = last
    last?.next = segment
    last = segment
  }
}
