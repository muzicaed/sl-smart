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
    mapView.mapType = MKMapType.Standard
    mapView.showsBuildings = true
    mapView.showsCompass = true
    mapView.showsPointsOfInterest = false
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
    var isShadow = false
    var zIndex = CGFloat(0)
    
    if annotation.isKindOfClass(BigPin) {
      let bigPinIcon = annotation as! BigPin
      if let name = bigPinIcon.imageName {
        image = UIImage(named: name)!
        bgColor = UIColor(white: 1.0, alpha: 0.9)
        isShadow = true
      }
      zIndex = 1
      
    } else if annotation.isKindOfClass(DestinationPin) {
      reuseId = "destination-dot"
      image = UIImage(named: "MapDestinationDot")!
      zIndex = 1
      
    } else if annotation.isKindOfClass(SmallPin) {
      reuseId = "small-dot"
      image = UIImage(named: "MapDotSmall")!
      zIndex = 1
      
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
      pinView!.layer.zPosition = zIndex
      if isShadow {
        pinView!.layer.masksToBounds = false
        pinView!.layer.shadowOffset = CGSizeMake(1, 1)
        pinView!.layer.shadowRadius = 5.0
        pinView!.layer.shadowColor = UIColor.blackColor().CGColor
        pinView!.layer.shadowOpacity = 0.45
        pinView!.clipsToBounds = false
        pinView!.layer.cornerRadius = 6
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
      for segment in trip.allTripSegments {
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
    if segment.stops.count == 0 {
      coords.append(segment.origin.location.coordinate)
      coords.append(segment.destination.location.coordinate)
    } else {
      for stop in segment.stops {
        coords.append(stop.location.coordinate)
      }
    }
    return coords
  }
  
  /**
   * Plots a trip segment route on map and
   * creates overlay icons.
   */
  private func createOverlays(coordinates: [CLLocationCoordinate2D], segment: TripSegment) {
    var newCoordinates = coordinates
    let polyline = RoutePolyline(coordinates: &newCoordinates, count: newCoordinates.count)
    polyline.segment = segment
    mapView.addOverlay(polyline)
    
    createStopPins(segment)
    createLocationPins(segment, coordinates: newCoordinates)
  }
  
  /**
   * Create location pins for each segment
   */
  private func createLocationPins(segment: TripSegment, coordinates: [CLLocationCoordinate2D]) {
    let originCoord = (segment.stops.count == 0) ? segment.origin.location.coordinate : segment.stops.first!.location.coordinate
    let destCoord = (segment.stops.count == 0) ? segment.destination.location.coordinate : segment.stops.last!.location.coordinate
    if segment == trip?.tripSegments.first! {
      let pin = BigPin()
      pin.coordinate = originCoord
      pin.title = "Start: " + segment.origin.name
      pin.subtitle = "Avgång: " + DateUtils.dateAsTimeString(segment.departureDateTime)
      pin.imageName = segment.type.rawValue
      mapView.addAnnotation(pin)
      mapView.selectAnnotation(pin, animated: true)
      return
    } else if segment == trip?.tripSegments.last! {
      let pin = BigPin()
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
      return
    }
    
    let pin = BigPin()
    pin.coordinate = originCoord
    pin.title = segment.origin.name
    pin.subtitle = "Avgång: " + DateUtils.dateAsTimeString(segment.departureDateTime)
    pin.imageName = segment.type.rawValue
    mapView.addAnnotation(pin)
  }
  
  /**
   * Create location pins for each stop
   */
  private func createStopPins(segment: TripSegment) {
    for stop in segment.stops {
      if stop.id != segment.stops.first!.id && stop.id != segment.stops.last!.id {
        let pin = SmallPin()
        pin.coordinate = stop.location.coordinate
        pin.title = stop.name
        if let depDate = stop.depDate {
          pin.subtitle = "Avgång: " + DateUtils.dateAsTimeString(depDate)
        }
        mapView.addAnnotation(pin)
      }
    }
  }
  
  /**
   * Centers and zooms map
   */
  private func setMapViewport(coordinates: [CLLocationCoordinate2D]) {
    var newCoordinates = coordinates
    let allPolyline = MKPolyline(coordinates: &newCoordinates, count: newCoordinates.count)
    self.mapView.setVisibleMapRect(
      self.mapView.mapRectThatFits(allPolyline.boundingMapRect),
      edgePadding: UIEdgeInsets(top: 100, left: 50, bottom: 100, right: 50),
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