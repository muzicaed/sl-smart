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
    mapView.mapType = MKMapType.Standard
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
    if let pinAnnotation = annotation as? DestinationPin {
      let pinView = TouchStationAnnotationView(annotation: pinAnnotation, reuseIdentifier: "dot")
      pinView.image = UIImage(named: "MapDestinationDot")!
      pinView.canShowCallout = true
      pinView.centerOffset = CGPointMake(0, 0)
      pinView.calloutOffset = CGPointMake(0, -3)
      
      let imageView = UIImageView(image: UIImage(named: "station-icon"))
      imageView.frame = CGRectMake(0, 0, 22, 22)
      pinView.leftCalloutAccessoryView = imageView
      
      return pinView
    }
    
    return nil
  }
  
  func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
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
      presentingViewController?.dismissViewControllerAnimated(true, completion: {})
    }
  }
  
  // MARK: Private
  
  
  /**
   * Prepares map data and placing pins.
   */
  private func loadMapData() {
    for (index, locationTuple) in nearbyLocations.enumerate() {
      createStopPin(index, locationTuple: locationTuple)
    }
  }
  
  /**
   * Create location pin
   */
  private func createStopPin(index: Int, locationTuple: (location: Location, dist: Int)) {
    let pin = DestinationPin()
    pin.coordinate = locationTuple.location.location.coordinate
    pin.title = locationTuple.location.name
    pin.subtitle = "Avstånd \(locationTuple.dist) meter"
    mapView.addAnnotation(pin)
  }
  
  /**
   * Centers & zooms map on pin
   */
  private func centerMap(location: CLLocation) {
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