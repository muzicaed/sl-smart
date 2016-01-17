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
    print("viewForAnnotation")
    return nil
  }
  
  /**
   * Render for map view
   */
  func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
    print("rendererForOverlay")
    if overlay.isKindOfClass(RoutePolyline) {
      print("RoutePolyLine")
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
      for (index, segment) in trip.tripSegments.enumerate() {
        var firstCoord: CLLocationCoordinate2D? = nil
        if (index + 1) < trip.tripSegments.count {
          let nextSegment = trip.tripSegments[index + 1]
          firstCoord = nextSegment.origin.location.coordinate
        }
        
        let coords = plotRoute(segment, firstCoordForNext: firstCoord)
        createOverlays(coords, segment: segment)
        allCoords += coords
      }
      
      setMapViewport(allCoords)
    }
  }
  
  /**
   * Plots the coordinates for the route.
   */
  private func plotRoute(segment: TripSegment,
    firstCoordForNext: CLLocationCoordinate2D?) -> [CLLocationCoordinate2D] {
      
      var coords = [CLLocationCoordinate2D]()
      if segment.routeLineLocations.count == 0 {
        coords.append(segment.origin.location.coordinate)
        coords.append(segment.destination.location.coordinate)
      } else {
        for location in segment.routeLineLocations {
          coords.append(location.coordinate)
        }
      }
      
      if let nextCoord = firstCoordForNext {
        coords.append(nextCoord)
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
    
    if segment == trip?.tripSegments.first! {
      let pin = MKPointAnnotation()
      pin.coordinate = coordinates.first!
      pin.title = segment.origin.name
      pin.subtitle = "Avgångstid: " + DateUtils.dateAsTimeString(segment.departureDateTime)
      mapView.addAnnotation(pin)
    } else if segment == trip?.tripSegments.last! {
      let pin = MKPointAnnotation()
      pin.coordinate = coordinates.last!
      pin.title = segment.destination.name
      pin.subtitle = "Framme: " + DateUtils.dateAsTimeString(segment.arrivalDateTime)
      mapView.addAnnotation(pin)
    } else {
      let pin = MKPointAnnotation()
      pin.coordinate = coordinates.last!
      pin.title = segment.destination.name
      pin.subtitle = "Avgångstid: " + DateUtils.dateAsTimeString(segment.departureDateTime)
      mapView.addAnnotation(pin)
    }
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
}