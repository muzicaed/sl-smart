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
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var mapView: MKMapView!
    var trip: Trip?
    var routePolylineViews = [MKPolylineView]()
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
        mapView.showsCompass = true
        mapView.showsPointsOfInterest = false
        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .never
        }
        
        activityIndicator.startAnimating()
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
        var allCoords = [CLLocationCoordinate2D]()
        if let trip = trip {
            for (index, segment) in trip.allTripSegments.enumerated() {
                
                let next: TripSegment? = (trip.allTripSegments.count > index + 1) ? trip.allTripSegments[index + 1] : nil
                let before: TripSegment? = (index > 0) ? trip.allTripSegments[index - 1] : nil
                let isLast = (segment == trip.allTripSegments.last)
                let coords = RoutePlotter.plotRoute(segment, before: before, next: next,
                                                    isLast: isLast, geoLocations: segment.geoRoute, mapView: self.mapView)
                allCoords.append(contentsOf: coords)
                
                RoutePlotter.createOverlays(segment.geoRoute, segment, trip, mapView, showStart: true)
            }
        }
        
        activityIndicator.stopAnimating()
        
        MapHelper.setMapViewport(mapView, coordinates: allCoords, topPadding: 150)
    }
}
