//
//  LocationMapVC.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-04-17.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import ResStockholmApiKit

class LocationMapVC: UIViewController, MKMapViewDelegate {
  
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var titleItem: UINavigationItem!
  var location: Location?
  
  
  /**
   * View did load
   */
  override func viewDidLoad() {
    mapView.delegate = self
    mapView.mapType = MKMapType.Standard
    mapView.showsBuildings = true
    mapView.showsCompass = true
    if let location = location {
      titleItem.title = location.cleanName
      createStopPin(location)
    }
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
    if annotation.isKindOfClass(BigPin) {
      let pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: "dot")
      pinView.image = UIImage(named: "MapDot")!
      pinView.canShowCallout = true
      pinView.centerOffset = CGPointMake(0, 0)
      pinView.calloutOffset = CGPointMake(0, -3)
      
      return pinView
    }
    
    return nil
  }
  
  // MARK: Private
  
  /**
   * Create location pin
   */
  private func createStopPin(location: Location) {
    let pin = BigPin()
    pin.coordinate = location.location.coordinate
    pin.title = location.name
    mapView.addAnnotation(pin)
    centerMap(pin)
  }
  
  /**
   * Centers & zooms map on pin
   */
  private func centerMap(pin: BigPin) {
    let region = MKCoordinateRegion(
      center: pin.coordinate,
      span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    
    mapView.setRegion(region, animated: true)
    mapView.regionThatFits(region)
    mapView.selectAnnotation(pin, animated: true)
  }
  
}