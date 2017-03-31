//
//  NearbyStationsMapVC.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-05-03.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import ResStockholmApiKit

class NearbyStationsMapVC: UIViewController, MKMapViewDelegate {
  
  @IBOutlet weak var mapView: MKMapView!
  var nearbyLocations = [(location: Location, dist: Int)]()
  var selectedPin: TouchStationAnnotationView?
  var nearbyStationsVC: NearbyStationsVC?
  
  /**
   * View did load
   */
  override func viewDidLoad() {
    mapView.delegate = self
    mapView.mapType = MKMapType.standard
    mapView.showsBuildings = true
    mapView.showsCompass = true
    mapView.showsTraffic = false
    mapView.showsPointsOfInterest = false
    
    loadMapData()
    if let currentLocation = MyLocationHelper.sharedInstance.currentLocation {
      centerMap(currentLocation)
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
    if let pinAnnotation = annotation as? DestinationPin {
      let pinView = TouchStationAnnotationView(annotation: pinAnnotation, reuseIdentifier: "dot")
      pinView.image = UIImage(named: "MapDestinationDot")!
      pinView.canShowCallout = true
      pinView.centerOffset = CGPoint(x: 0, y: 0)
      pinView.calloutOffset = CGPoint(x: 0, y: -3)
      pinView.stationIndex = pinAnnotation.stationIndex
      
      let imageView = UIImageView(image: UIImage(named: "station-icon"))
      imageView.frame = CGRect(x: 0, y: 0, width: 22, height: 22)
      pinView.leftCalloutAccessoryView = imageView
      
      return pinView
    }
    
    return nil
  }
  
  func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    if let touchPinView = view as? TouchStationAnnotationView {
      selectedPin = touchPinView
      let g = UITapGestureRecognizer(target: self, action: #selector(onCalloutTap))
      view.addGestureRecognizer(g)
    }
  }
  
  
  func onCalloutTap() {
    if let index = selectedPin?.stationIndex {
      let locationTuple = nearbyLocations[index]
      self.nearbyStationsVC?.selectedOnMap(locationTuple.location)
      presentingViewController?.dismiss(animated: true, completion: {})
    }
  }
  
  // MARK: Private
  
  
  /**
   * Prepares map data and placing pins.
   */
  fileprivate func loadMapData() {
    for (index, locationTuple) in nearbyLocations.enumerated() {
      createStopPin(index: index, locationTuple: locationTuple)
    }
  }
  
  /**
   * Create location pin
   */
  fileprivate func createStopPin(index: Int, locationTuple: (location: Location, dist: Int)) {
    if let loc = locationTuple.location.location {
      let pin = DestinationPin()
      pin.coordinate = loc.coordinate
      pin.title = locationTuple.location.name
      pin.stationIndex = index
      pin.subtitle = String(format: "Distance %d meters".localized, locationTuple.dist)      
      mapView.addAnnotation(pin)
    }
  }
  
  /**
   * Centers & zooms map on pin
   */
  fileprivate func centerMap(_ location: CLLocation) {
    let region = MKCoordinateRegion(
      center: location.coordinate,
      span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    
    mapView.setRegion(region, animated: true)
    mapView.regionThatFits(region)
  }
}


/**
 * Custom tocuh station annotation view.
 */
class TouchStationAnnotationView: MKAnnotationView {
  var stationIndex = -1
}
