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
  
  /**
   * Plots a trip segment route on map and
   * creates overlay icons.
   */
  static func createOverlays(_ coordinates: [CLLocationCoordinate2D],
                             _ segment: TripSegment,
                             _ trip: Trip?,
                             _ mapView: MKMapView) {
    var newCoordinates = coordinates
    let polyline = RoutePolyline(coordinates: &newCoordinates, count: newCoordinates.count)
    polyline.segment = segment
    mapView.add(polyline)
    
    createStopPins(segment, mapView: mapView)
    createLocationPins(segment, coordinates: newCoordinates, trip, mapView)
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
  
  /**
   * Create location pins for each segment
   */
  static fileprivate func createLocationPins(_ segment: TripSegment,
                                             coordinates: [CLLocationCoordinate2D],
                                             _ trip: Trip?,
                                             _ mapView: MKMapView) {
    
    if let originLocation = segment.origin.location, let destLocation = segment.destination.location {
      let originCoord = (segment.stops.count == 0) ? originLocation.coordinate : segment.stops.first!.location.coordinate
      let destCoord = (segment.stops.count == 0) ? destLocation.coordinate : segment.stops.last!.location.coordinate
      
      let pin = BigPin()
      pin.zIndexMod = (segment.type == .Walk) ? -1 : 1
      if segment == trip?.tripSegments.first! {
        pin.coordinate = originCoord
        pin.title = "Start: " + segment.origin.name
        pin.subtitle = "Avgång: " + DateUtils.dateAsTimeString(segment.departureDateTime)
        pin.imageName = segment.type.rawValue
        mapView.addAnnotation(pin)
        //mapView.selectAnnotation(pin, animated: false)
      }
      if segment == trip?.tripSegments.last! {
        pin.coordinate = originCoord
        pin.title = segment.origin.name
        pin.subtitle = "Avgång: " + DateUtils.dateAsTimeString(segment.departureDateTime)
        pin.imageName = segment.type.rawValue
        mapView.addAnnotation(pin)
        
        let destPin = DestinationPin()
        destPin.coordinate = destCoord
        destPin.title = "Destination: " + segment.destination.name
        destPin.subtitle = "Framme: " + DateUtils.dateAsTimeString(segment.arrivalDateTime)
        mapView.addAnnotation(destPin)
      }
      if segment != trip?.tripSegments.first! && segment != trip?.tripSegments.last! {
        pin.coordinate = originCoord
        pin.title = segment.origin.name
        pin.subtitle = "Avgång: " + DateUtils.dateAsTimeString(segment.departureDateTime)
        pin.imageName = segment.type.rawValue
        mapView.addAnnotation(pin)
      }
    }
  }
  
  /**
   * Create location pins for each stop
   */
  static fileprivate func createStopPins(_ segment: TripSegment, mapView: MKMapView) {
    for stop in segment.stops {
      if stop.id != segment.stops.first!.id && stop.id != segment.stops.last!.id {
        let pin = SmallPin()
        pin.coordinate = stop.location.coordinate
        pin.title = stop.name
        if let depDate = stop.depDate {
          pin.subtitle = "Avgång: " + DateUtils.dateAsTimeString(depDate)
        }
        pin.imageName = segment.type.rawValue + "-SMALL"
        mapView.addAnnotation(pin)
      }
    }
  }
}
