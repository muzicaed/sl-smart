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
    } else {
      setupWalkRenderer()
    }
  }
  
  /**
   * Setup renderer based on trip type
   */
  fileprivate func setupRenderer(_ segment: TripSegment) {
    let data = TripHelper.friendlyLineData(segment)
    self.strokeColor = data.color
    self.lineJoin = CGLineJoin.bevel
    self.lineWidth = 4.5
    if segment.type == .Ferry || segment.type == .Walk {
      self.strokeColor = UIColor.black
      self.lineWidth = 2.5
      self.lineDashPattern = [6, 8]
    }
  }
  
  /**
   * Setup renderer based on walk trip type
   */
  fileprivate func setupWalkRenderer() {
    self.strokeColor = UIColor.black
    self.lineWidth = 3.5
    //self.lineDashPattern = [6, 8]
  }
}
