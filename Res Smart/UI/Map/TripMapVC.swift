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
  
  /**
   * View did load
   */
  override func viewDidLoad() {
    mapView.delegate = self
    loadRoute()
  }
  
  /**
   * User tapped close
   */
  @IBAction func onCloseTap(sender: AnyObject) {
    presentingViewController?.dismissViewControllerAnimated(true, completion: {})
  }
  
  /**
   * Map type segment changed
   */
  @IBAction func onSegmentChanged(sender: UISegmentedControl) {
    switch sender.selectedSegmentIndex {
    case 0:
      mapView.mapType = MKMapType.Standard
    case 1:
      mapView.mapType = MKMapType.Hybrid
    default: break
    }
  }
  
  /**
   * User tapped my position
   */
  @IBAction func myPositionTap(sender: AnyObject) {
    if mapView.showsUserLocation {
      mapView.setCenterCoordinate(mapView.userLocation.coordinate, animated: true)
    } else {
      mapView.showsUserLocation = true
    }
  }
  
  // MARK: MKMapViewDelegate
  
  /**
  * Annotation views
  */
  func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
    
    var reuseId: String? = nil
    var image: UIImage? = nil
    var bgColor = UIColor.clearColor()
    var isShaddow = false
    
    if annotation.isKindOfClass(BigPin) {
      reuseId = "dot"
      image = UIImage(named: "MapDot")!
      
    } else if annotation.isKindOfClass(OriginPin) {
      reuseId = "origin-dot"
      image = UIImage(named: "MapOriginDot")!
      
    } else if annotation.isKindOfClass(SmallPin) {
      reuseId = "small-dot"
      image = UIImage(named: "MapDotSmall")!
      
    } else if annotation.isKindOfClass(TripTypeIconAnnotation) {
      let tripTypeIcon = annotation as! TripTypeIconAnnotation
      if let name = tripTypeIcon.imageName {
        image = UIImage(named: name)!
        bgColor = UIColor(white: 1.0, alpha: 0.8)
        isShaddow = true
      }
    } else {
      return nil
    }
    
    var pinView: MKAnnotationView? = nil
    if let id = reuseId {
      pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(id)
    }
    if pinView == nil {
      pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
      pinView!.canShowCallout = true
      pinView!.centerOffset = CGPointMake(0, 0)
      pinView!.calloutOffset = CGPointMake(0, -3)
      pinView!.backgroundColor = bgColor
      if isShaddow {
        pinView!.layer.masksToBounds = false
        pinView!.layer.shadowOffset = CGSizeMake(1, 1)
        pinView!.layer.shadowRadius = 5.0
        pinView!.layer.shadowColor = UIColor.blackColor().CGColor
        pinView!.layer.shadowOpacity = 0.45
        pinView!.clipsToBounds = false
      }
      if let img = image {
        pinView!.image = img
      }
    }
    return pinView
  }
  
  /**
   * Render for map view
   */
  func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
    if overlay.isKindOfClass(RoutePolyline) {
      let render = RouteRenderer(overlay: overlay)
      return render
    }
    return MKOverlayRenderer()
  }
  
  // MARK: Private
  
  /**
  * Loads map route
  */
  private func loadRoute() {
    if let trip = trip {
      var allCoords = [CLLocationCoordinate2D]()
      for segment in trip.tripSegments {        
        let coords = plotRoute(segment)
        createOverlays(coords, segment: segment)
        allCoords += coords
      }
      
      setMapViewport(allCoords)
    }
  }
  
  /**
   * Plots the coordinates for the route.
   */
  private func plotRoute(segment: TripSegment) -> [CLLocationCoordinate2D] {
      
      var coords = [CLLocationCoordinate2D]()
      if segment.routeLineLocations.count == 0 {
        coords.append(segment.origin.location.coordinate)
        coords.append(segment.destination.location.coordinate)
      } else {
        for location in segment.routeLineLocations {
          coords.append(location.coordinate)
        }
        coords.append(segment.destination.location.coordinate)
      }
      
      return coords
  }
  
  /**
   * Plots a trip segment route on map and
   * creates overlay icons.
   */
  private func createOverlays(var coordinates: [CLLocationCoordinate2D], segment: TripSegment) {
    let polyline = RoutePolyline(coordinates: &coordinates, count: coordinates.count)
    polyline.segment = segment
    mapView.addOverlay(polyline)
    
    createStopPins(segment)
    createLocationPins(segment, coordinates: coordinates)
    createTripTypeIcon(segment, coordinates: coordinates)
  }
  
  /**
   * Create location pins for each segment
   */
  private func createLocationPins(segment: TripSegment, coordinates: [CLLocationCoordinate2D]) {
    if segment == trip?.tripSegments.first! {
      let pin = OriginPin()
      pin.coordinate = segment.origin.location.coordinate
      pin.title = "Start: " + segment.origin.name
      pin.subtitle = "Avgång: " + DateUtils.dateAsTimeString(segment.departureDateTime)
      mapView.addAnnotation(pin)
    } else if segment == trip?.tripSegments.last! {
      let pin = BigPin()
      pin.coordinate = segment.destination.location.coordinate
      pin.title = "Destination: " + segment.destination.name
      pin.subtitle = "Framme: " + DateUtils.dateAsTimeString(segment.arrivalDateTime)
      mapView.addAnnotation(pin)
      return
    } else {
      let pin = BigPin()
      print(segment.origin.name)
      pin.coordinate = segment.origin.location.coordinate
      pin.title = segment.origin.name
      pin.subtitle = "Avgång: " + DateUtils.dateAsTimeString(segment.departureDateTime)
      mapView.addAnnotation(pin)
    }
    
    let destPin = BigPin()
    destPin.coordinate = segment.destination.location.coordinate
    destPin.title = segment.destination.name
    destPin.subtitle = "Avgång: " + DateUtils.dateAsTimeString(segment.departureDateTime)
    mapView.addAnnotation(destPin)
  }
  
  /**
   * Create location pins for each stop
   */
  private func createStopPins(segment: TripSegment) {
    for stop in segment.stops {
      let pin = SmallPin()
      pin.coordinate = stop.location.coordinate
      pin.title = stop.name
      if let depDate = stop.depDate {
        pin.subtitle = "Avgång: " + DateUtils.dateAsTimeString(depDate)
      }
      mapView.addAnnotation(pin)
    }
  }
  
  /**
   * Create trip type annotation icons.
   */
  private func createTripTypeIcon(segment: TripSegment, coordinates: [CLLocationCoordinate2D]) {
    
    var coord = CLLocationCoordinate2D()
    if coordinates.count > 2 {
      coord = findCenterCoordinate(
        coordinates[Int(floor(Float(coordinates.count / 2)) - 1)],
        coord2: coordinates[Int(ceil(Float(coordinates.count / 2)) + 1)])
    } else {
      coord = findCenterCoordinate(coordinates.first!, coord2: coordinates.last!)
    }
    
    
    let data = TripHelper.friendlyLineData(segment)
    let pin = TripTypeIconAnnotation()
    pin.coordinate = coord
    pin.imageName = data.icon
    pin.title = data.long
    
    mapView.addAnnotation(pin)
  }
  
  /**
   * Centers and zooms map
   */
  private func setMapViewport(var coordinates: [CLLocationCoordinate2D]) {
    let allPolyline = MKPolyline(coordinates: &coordinates, count: coordinates.count)
    self.mapView.setVisibleMapRect(
      self.mapView.mapRectThatFits(allPolyline.boundingMapRect),
      edgePadding: UIEdgeInsetsMake(50, 50, 50, 50),
      animated: false)
  }
  
  
  /**
   * Find coordinate between two coordinates.
   */
  private func findCenterCoordinate(
    coord1: CLLocationCoordinate2D, coord2: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
      
      let lon1 = Double(coord1.longitude) * M_PI / 180
      let lon2 = Double(coord2.longitude) * M_PI / 180
      
      let lat1 = Double(coord1.latitude) * M_PI / 180
      let lat2 = Double(coord2.latitude) * M_PI / 180
      
      let dLon = lon2 - lon1
      
      let x = cos(lat2) * cos(dLon)
      let y = cos(lat2) * sin(dLon)
      
      let lat3 = atan2( sin(lat1) + sin(lat2), sqrt((cos(lat1) + x) * (cos(lat1) + x) + y * y) )
      let lon3 = lon1 + atan2(y, cos(lat1) + x)
      
      return CLLocationCoordinate2D(latitude: lat3 * 180 / M_PI, longitude: lon3 * 180 / M_PI)
  }
}