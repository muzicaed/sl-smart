//
//  TripMapVC.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-01-16.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import ResStockholmApiKit

class TripMapVC: UIViewController, MKMapViewDelegate {
  
  @IBOutlet weak var mapView: MKMapView!
  var trip: Trip?
  var routePolylineViews = [MKPolylineView]()
  var smallPins = [SmallPin]()
  var isSmallPinsVisible = true
  
  /**
   * View did load
   */
  override func viewDidLoad() {
    mapView.delegate = self
    mapView.mapType = MKMapType.standard
    mapView.showsBuildings = true
    mapView.showsCompass = true
    mapView.showsPointsOfInterest = false
    loadRoute()
  }
  
  /**
   * User tapped close
   */
  @IBAction func onCloseTap(_ sender: AnyObject) {
    presentingViewController?.dismiss(animated: true, completion: {})
  }
  
  /**
   * Map type segment changed
   */
  @IBAction func onSegmentChanged(_ sender: UISegmentedControl) {
    switch sender.selectedSegmentIndex {
    case 0:
      mapView.mapType = MKMapType.standard
    case 1:
      mapView.mapType = MKMapType.hybrid
    default: break
    }
  }
  
  /**
   * User tapped my position
   */
  @IBAction func myPositionTap(_ sender: AnyObject) {
    if mapView.showsUserLocation {
      mapView.setCenter(mapView.userLocation.coordinate, animated: true)
    } else {
      mapView.showsUserLocation = true
    }
  }
  
  // MARK: MKMapViewDelegate
  
  /**
   * Annotation views
   */
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    var reuseId: String? = nil
    var image: UIImage? = nil
    var zIndex = CGFloat(0)
    
    if annotation.isKind(of: BigPin.self) {
      let bigPinIcon = annotation as! BigPin
      if let name = bigPinIcon.imageName {
        image = UIImage(named: name)!
        reuseId = name
      }
      zIndex = 2 + bigPinIcon.zIndexMod
      
    } else if annotation.isKind(of: DestinationPin.self) {
      reuseId = "destination-dot"
      image = UIImage(named: "MapDestinationDot")!
      zIndex = 3
      
    } else if annotation.isKind(of: SmallPin.self) {
      let pinIcon = annotation as! SmallPin
      if let name = pinIcon.imageName {
        image = UIImage(named: name)!
        reuseId = name
      }
      smallPins.append(pinIcon)
      zIndex = 1
      
    } else {
      return nil
    }
    
    var pinView: MKAnnotationView? = nil
    if let id = reuseId {
      pinView = mapView.dequeueReusableAnnotationView(withIdentifier: id)
    }
    if pinView == nil {
      pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
      pinView!.canShowCallout = true
      pinView!.centerOffset = CGPoint(x: 0, y: 0)
      pinView!.calloutOffset = CGPoint(x: 0, y: -3)
      pinView!.layer.zPosition = zIndex
      if let img = image {
        pinView!.image = img
      }
    }
    return pinView
  }
  
  /**
   * Render for map view
   */
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    if overlay.isKind(of: MKPolyline.self) {
      let render = RouteRenderer(overlay: overlay)
      return render
    }
    return MKOverlayRenderer()
  }
  
  func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
    if (mapView.region.span.latitudeDelta > 0.20) {
      if isSmallPinsVisible {
        mapView.removeAnnotations(smallPins)
        isSmallPinsVisible = false
      }
    } else {
      if !isSmallPinsVisible {
        isSmallPinsVisible = true
        mapView.addAnnotations(smallPins)
      }
    }
  }
  
  // MARK: Private
  
  /**
   * Loads map route
   */
  fileprivate func loadRoute() {
    if let trip = trip {
      var allCoords = [CLLocationCoordinate2D]()
      for (index, segment) in trip.allTripSegments.enumerated() {
        let next: TripSegment? = (trip.allTripSegments.count > index + 1) ? trip.allTripSegments[index + 1] : nil
        let before: TripSegment? = (index > 0) ? trip.allTripSegments[index - 1] : nil
        let isLast = (segment == trip.allTripSegments.last)
        let coords = plotRoute(segment, before: before, next: next, isLast: isLast)
        createOverlays(coords, segment: segment)
        allCoords += coords
      }
      
      setMapViewport(allCoords)
    }
  }
  
  /**
   * Plots the coordinates for the route.
   */
  
  fileprivate func plotRoute(_ segment: TripSegment, before: TripSegment?, next: TripSegment?, isLast: Bool) -> [CLLocationCoordinate2D] {
    var coords = [CLLocationCoordinate2D]()
    if canPlotRoute(segment, before: before, next: next, isLast: isLast) {
      plotWalk(segment)
    } else {
      if segment.stops.count == 0 {
        coords.append(segment.origin.location.coordinate)
        coords.append(segment.destination.location.coordinate)
      } else {
        for stop in segment.stops {
          coords.append(stop.location.coordinate)
        }
      }
    }
    
    return coords
  }
  
  /**
   * Check if segment can be ploted as walk route.
   */
  fileprivate func canPlotRoute(_ segment: TripSegment, before: TripSegment?, next: TripSegment?, isLast: Bool) -> Bool {
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
  fileprivate func plotWalk(_ segment: TripSegment) {
    let source = MKMapItem(placemark: MKPlacemark(coordinate: segment.origin.location.coordinate, addressDictionary: nil))
    let dest = MKMapItem(placemark: MKPlacemark(coordinate: segment.destination.location.coordinate, addressDictionary: nil))
    
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
          self.mapView.add(route.polyline, level: .aboveRoads)
        }
    }
  }
  
  /**
   * Plots a trip segment route on map and
   * creates overlay icons.
   */
  fileprivate func createOverlays(_ coordinates: [CLLocationCoordinate2D], segment: TripSegment) {
    var newCoordinates = coordinates
    let polyline = RoutePolyline(coordinates: &newCoordinates, count: newCoordinates.count)
    polyline.segment = segment
    mapView.add(polyline)
    
    createStopPins(segment)
    createLocationPins(segment, coordinates: newCoordinates)
  }
  
  /**
   * Create location pins for each segment
   */
  fileprivate func createLocationPins(_ segment: TripSegment, coordinates: [CLLocationCoordinate2D]) {
    let originCoord = (segment.stops.count == 0) ? segment.origin.location.coordinate : segment.stops.first!.location.coordinate
    let destCoord = (segment.stops.count == 0) ? segment.destination.location.coordinate : segment.stops.last!.location.coordinate
    let pin = BigPin()
    pin.zIndexMod = (segment.type == .Walk) ? -1 : 0
    if segment == trip?.tripSegments.first! {
      pin.coordinate = originCoord
      pin.title = "Start: " + segment.origin.name
      pin.subtitle = "Avgång: " + DateUtils.dateAsTimeString(segment.departureDateTime)
      pin.imageName = segment.type.rawValue
      mapView.addAnnotation(pin)
      mapView.selectAnnotation(pin, animated: false)
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
  
  /**
   * Create location pins for each stop
   */
  fileprivate func createStopPins(_ segment: TripSegment) {
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
  
  /**
   * Centers and zooms map
   */
  fileprivate func setMapViewport(_ coordinates: [CLLocationCoordinate2D]) {
    var newCoordinates = coordinates
    let allPolyline = MKPolyline(coordinates: &newCoordinates, count: newCoordinates.count)
    
    self.mapView.setVisibleMapRect(
      self.mapView.mapRectThatFits(allPolyline.boundingMapRect),
      edgePadding: UIEdgeInsets(top: 100, left: 50, bottom: 100, right: 50),
      animated: false)
  }
}
