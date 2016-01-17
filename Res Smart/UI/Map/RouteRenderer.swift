//
//  RouteRenderer.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-01-17.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation
import MapKit
import ResStockholmApiKit

class RouteRenderer: MKPolylineRenderer {
  
  override init(overlay: MKOverlay) {
    super.init(overlay: overlay)
    if let routePolyline = overlay as? RoutePolyline {
      if let segment = routePolyline.segment {
        setupRenderer(segment)
      }
    }
    
  }
  
  /**
   * Setup renderer based on trip type
   */
  private func setupRenderer(segment: TripSegment) {
    self.strokeColor = UIColor(red: 21/255, green: 96/255, blue: 160/255, alpha: 1.0)
    self.lineJoin = CGLineJoin.Bevel
    self.lineWidth = 4.5
    switch segment.type {
    case .Walk, .Ferry:
      self.strokeColor = UIColor(white: 0.15, alpha: 1.0)
      self.lineWidth = 3.5
      self.lineDashPattern = [6, 8]
    case .Bus:
        self.strokeColor = UIColor(red: 192/255, green: 27/255, blue: 56/255, alpha: 1.0)
    default:
      break
    }
  }
}