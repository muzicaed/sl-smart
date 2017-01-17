//
//  CurrentTripVC.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-08-09.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit
import ResStockholmApiKit
import MapKit

class CurrentTripVC: UIViewController, MKMapViewDelegate {

  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var stepByStepView: StepByStepView!
  
  var currentTrip: Trip?
  var allCords = [CLLocationCoordinate2D]()
  var noOfSegments = 0
  var loadedSegmentsCount = 0
  var routeTuples = [([CLLocationCoordinate2D], TripSegment)]()
  var smallPins = [SmallPin]()
  var isSmallPinsVisible = true
  
  /**
   * View did load
   */
  override func viewDidLoad() {
    super.viewDidLoad()
    mapView.delegate = self
    mapView.mapType = MKMapType.standard
    mapView.showsBuildings = true
    mapView.showsCompass = false
    mapView.showsUserLocation = true
    mapView.showsPointsOfInterest = false
    loadRoute()
  }
  
  /**
   * Close and terminate current trip.
   */
  @IBAction func closeCurrentTrip(_ sender: UIBarButtonItem) {
    dismiss(animated: true, completion: nil)
  }
  
  // MARK: MKMapViewDelegate <- TOTO Could this be an extention?
  
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
    if let trip = currentTrip {
      noOfSegments = trip.allTripSegments.count
      for (index, segment) in trip.allTripSegments.enumerated() {
        let next: TripSegment? = (trip.allTripSegments.count > index + 1) ? trip.allTripSegments[index + 1] : nil
        let before: TripSegment? = (index > 0) ? trip.allTripSegments[index - 1] : nil
        let isLast = (segment == trip.allTripSegments.last)
        if let geoRef = segment.geometryRef {
          GeometryService.fetchGeometry(geoRef, callback: { (locations, error) in
            DispatchQueue.main.async {
              self.loadedSegmentsCount += 1
              let coords = RoutePlotter.plotRoute(segment, before: before, next: next,
                                                  isLast: isLast, geoLocations: locations, mapView: self.mapView)
              self.loadRouteDone(coords: coords, segment: segment)
            }
          })
        }
      }
    }
  }
  
  /**
   * Create overlay on rote plot done
   */
  fileprivate func loadRouteDone(coords: [CLLocationCoordinate2D], segment: TripSegment) {
    allCords += coords
    let routeTuple = (coords, segment)
    routeTuples.append(routeTuple)
    if loadedSegmentsCount == noOfSegments {
      //activityIndicator.stopAnimating()
      for tuple in routeTuples {
        RoutePlotter.createOverlays(tuple.0, tuple.1, currentTrip, mapView)
      }
      mapView.isHidden = false
      setMapViewport([currentTrip!.allTripSegments.first!.origin.location!.coordinate, currentTrip!.allTripSegments.first!.destination.location!.coordinate])
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
      edgePadding: UIEdgeInsets(top: 250, left: 25, bottom: 50, right: 25),
      animated: false)
  }
}
