//
//  CurrentTripAnalyzer.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2017-01-24.
//  Copyright © 2017 Mikael Hellman. All rights reserved.
//

import Foundation
import ResStockholmApiKit
import MapKit

class CurrentTripAnalyzer {
  
  fileprivate var segments = SegmentWrapperList()
  fileprivate var currentSpeed = SpeedType.Waiting
  
  
  /**
   * Prepare the analyzer
   */
  func addSegment(_ segment: TripSegment) {
    segments.append(SegmentWrapper(segment))
  }
  
  /**
   * Finds current active segment.
   */
  func findActiveSegment() -> Instruction {
    analyzeSpeed()
    return Instruction(segment: segments.first!.segment, type: .Riding, index: 0)
  }
  
  /**
   * Finds the next segment
   */
  func findNextStep() -> Instruction? {
    return Instruction(segment: segments.first!.segment, type: .Riding, index: 0)
  }
  
  /**
   * Analyzes speed
   */
  fileprivate func analyzeSpeed() {
    if let location = MyLocationHelper.sharedInstance.getCurrentLocation(), let loc = location.location {
      if loc.speed < 1 {
        currentSpeed = .Waiting
      } else if loc.speed < 6.5 {
        currentSpeed = .Walking
      }
      currentSpeed = .Riding
    }
  }
}


public enum InstructionType: String {
  case Riding = "RIDING"
  case Walking = "WALKING"
  case Waiting = "WAITING"
  case Arrived = "ARRIVIED"
}

public enum SpeedType: String {
  case Riding = "RIDING"
  case Walking = "WALKING"
  case Waiting = "WAITING"
}
