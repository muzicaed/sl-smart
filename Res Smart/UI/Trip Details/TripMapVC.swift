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
      mapView.mapType = MKMapType.Satellite
    case 2:
      mapView.mapType = MKMapType.Hybrid
    default: break
    }
  }
  
  /**
   * User tapped my position
   */
  @IBAction func myPositionTap(sender: AnyObject) {
    if mapView.showsUserLocation {
      if mapView.userLocationVisible {
        mapView.showsUserLocation = false
      } else {
        mapView.setCenterCoordinate(mapView.userLocation.coordinate, animated: true)
      }
    } else {
      mapView.showsUserLocation = true
    }
  }
  
  // MARK: MKMapViewDelegate
  
  /**
  * Render for map view
  */
  func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
    if let polylineOverlay = overlay as? MKPolyline {
      let render = MKPolylineRenderer(polyline: polylineOverlay)
      render.strokeColor = StyleHelper.sharedInstance.mainGreen
      render.alpha = 0.9
      render.lineWidth = 3.5
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
        var coords = [CLLocationCoordinate2D]()
        if let lastCoord = allCoords.last {
          coords.append(lastCoord)
        }
        
        if segment.routeLineLocations.count == 0 {
          coords.append(segment.origin.location.coordinate)
          coords.append(segment.destination.location.coordinate)
        } else {
          for location in segment.routeLineLocations {
            coords.append(location.coordinate)
          }
        }
        
        plotRoute(coords, segment: segment)
        allCoords += coords
      }
      
      let allPolyline = MKPolyline(coordinates: &allCoords, count: allCoords.count)
      self.mapView.setVisibleMapRect(
        self.mapView.mapRectThatFits(allPolyline.boundingMapRect),
        edgePadding: UIEdgeInsetsMake(50, 50, 50, 50),
        animated: false)
    }
  }
  
  /**
   * Plots a trip segment route on map
   */
  private func plotRoute(var coordinates: [CLLocationCoordinate2D], segment: TripSegment) {
    let polyline = MKPolyline(coordinates: &coordinates, count: coordinates.count)
    mapView.addOverlay(polyline)

  }
}