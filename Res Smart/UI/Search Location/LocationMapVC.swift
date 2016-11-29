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
    mapView.mapType = MKMapType.standard
    mapView.showsBuildings = true
    mapView.showsCompass = true
    mapView.showsPointsOfInterest = false
    if let location = location {
      titleItem.title = location.cleanName
      createStopPin(location)
    }
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
    if annotation.isKind(of: BigPin.self) {
      let pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: "dot")
      pinView.image = UIImage(named: "MapDestinationDot")!
      pinView.canShowCallout = true
      pinView.centerOffset = CGPoint(x: 0, y: 0)
      pinView.calloutOffset = CGPoint(x: 0, y: -3)
      
      return pinView
    }
    
    return nil
  }
  
  // MARK: Private
  
  /**
   * Create location pin
   */
  fileprivate func createStopPin(_ location: Location) {
    let pin = BigPin()
    pin.coordinate = location.location.coordinate
    pin.title = location.name
    mapView.addAnnotation(pin)
    centerMap(pin)
  }
  
  /**
   * Centers & zooms map on pin
   */
  fileprivate func centerMap(_ pin: BigPin) {
    let region = MKCoordinateRegion(
      center: pin.coordinate,
      span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    
    mapView.setRegion(region, animated: true)
    mapView.regionThatFits(region)
    mapView.selectAnnotation(pin, animated: true)
  }
  
}
