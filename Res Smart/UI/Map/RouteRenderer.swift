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
    let data = TripHelper.friendlyLineData(segment)
    self.strokeColor = data.color
    self.lineJoin = CGLineJoin.Bevel
    self.lineWidth = 4.5
    if segment.type == .Walk || segment.type == .Ferry {
      self.strokeColor = UIColor.blackColor()
      self.lineWidth = 3.5
      self.lineDashPattern = [6, 8]
    }
  }
}