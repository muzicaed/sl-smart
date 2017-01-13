//
//  RoutePlotter.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2017-01-13.
//  Copyright © 2017 Mikael Hellman. All rights reserved.
//

import Foundation
import MapKit
import ResStockholmApiKit

class RoutePlotter {
  /**
   * Plots the coordinates for the route.
   */
  
  static func plotRoute(_ segment: TripSegment,
                             before: TripSegment?,
                             next: TripSegment?,
                             isLast: Bool, geoLocations: [CLLocation],
                             mapView: MKMapView) -> [CLLocationCoordinate2D] {
    
    var coords = [CLLocationCoordinate2D]()
    if canPlotRoute(segment, before: before, next: next, isLast: isLast) {
      plotWalk(segment, mapView)
    } else {
      if segment.stops.count == 0 {
        if let originLocation = segment.origin.location, let destLocation = segment.destination.location {
          coords.append(originLocation.coordinate)
          coords.append(destLocation.coordinate)
        }
      } else {
        var shouldPlot = false
        if let originLocation = segment.origin.location, let destLocation = segment.destination.location {
          coords.append(originLocation.coordinate)
          for location in geoLocations {
            if location.distance(from: originLocation) < 1  {
              shouldPlot = true
            }
            if shouldPlot == true && location.distance(from: destLocation) < 1 {
              break
            }
            if shouldPlot {
              coords.append(location.coordinate)
            }
          }
          coords.append(destLocation.coordinate)
        }
      }
    }
    
    return coords
  }
  
  // MARK: Private
  
  /**
   * Check if segment can be ploted as walk route.
   */
  static fileprivate func canPlotRoute(_ segment: TripSegment, before: TripSegment?, next: TripSegment?, isLast: Bool) -> Bool {
    return (
      segment.type == .Walk &&
        (
          (segment.origin.type == .Address || segment.destination.type == .Address) ||
            ((before?.type == .Bus || before == nil) && (next?.type == .Bus || isLast))
      )
    )
  }
  
  /**
   * Plot a walk segment using directions
   */
  static fileprivate func plotWalk(_ segment: TripSegment, _ mapView: MKMapView) {
    if let originLocation = segment.origin.location, let destLocation = segment.destination.location {
      let source = MKMapItem(placemark: MKPlacemark(coordinate: originLocation.coordinate, addressDictionary: nil))
      let dest = MKMapItem(placemark: MKPlacemark(coordinate: destLocation.coordinate, addressDictionary: nil))
      
      let directionRequest = MKDirectionsRequest()
      directionRequest.source = source
      directionRequest.destination = dest
      directionRequest.transportType = .walking
      
      MKDirections(request: directionRequest)
        .calculate { (response, error) -> Void in
          
          guard let response = response else {
            if let error = error {
              fatalError("Error: \(error)")
            }
            return
          }
          
          if let route = response.routes.first {
            mapView.add(route.polyline, level: .aboveRoads)
          }
      }
    }
  }
  

}
