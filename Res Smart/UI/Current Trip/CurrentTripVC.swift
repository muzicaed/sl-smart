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
  @IBOutlet weak var nextStepView: StepByStepView!
  @IBOutlet weak var autoManualSegmentControl: UISegmentedControl!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  
  let analyzer = CurrentTripAnalyzer()
  var currentTrip: Trip?
  var allCords = [CLLocationCoordinate2D]()
  var noOfSegments = 0
  var loadedSegmentsCount = 0
  var routeTuples = [([CLLocationCoordinate2D], TripSegment)]()
  var smallPins = [SmallPin]()
  var isSmallPinsVisible = true
  var isMapLoaded = false
  var isOverviewLocked = true
  var refreshTimer: Timer?
  var currentSegmentIndex = 0
  
  /**
   * View did load
   */
  override func viewDidLoad() {
    super.viewDidLoad()
    prepareMapView()
    if !isMapLoaded {
      stepByStepView.isHidden = true
      nextStepView.isHidden = true
      activityIndicator.startAnimating()
      analyzer.currentTrip = currentTrip
      loadRoute()
    }
    if let last = currentTrip?.allTripSegments.last {
      title = "Till \(last.destination.name)"
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    startRefreshTimmer()
    if isMapLoaded {
      updateTripStatus()
    }
  }
  
  /**
   * View about to disappear
   */
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    stopRefreshTimmer()
  }
  
  /**
   * Returned to the app.
   */
  func didBecomeActive() {
    updateTripStatus()
    startRefreshTimmer()
  }
  
  /**
   * Backgrounded.
   */
  func didBecomeInactive() {
    stopRefreshTimmer()
  }
  
  /**
   * Start refresh timmer
   */
  func startRefreshTimmer() {
    stopRefreshTimmer()
    self.refreshTimer = Timer.scheduledTimer(
      timeInterval: 15, target: self, selector: #selector(updateTripStatus), userInfo: nil, repeats: true)
  }
  
  /**
   * Stop refresh timmer
   */
  func stopRefreshTimmer() {
    self.refreshTimer?.invalidate()
    self.refreshTimer = nil
  }
  
  /**
   * Close and terminate current trip.
   */
  @IBAction func closeCurrentTrip(_ sender: UIBarButtonItem) {
    dismiss(animated: true, completion: nil)
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
   * Auto/Manual map update changed
   */
  @IBAction func onAutoManualChanged(_ sender: UISegmentedControl) {
    if autoManualSegmentControl.selectedSegmentIndex == 0 {
      isOverviewLocked = true
      disableMapScroll()
      updateTripStatus()
    } else {
      isOverviewLocked = false
      enableMapScroll()
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
  
  /**
   * Update the trip views
   */
  @objc fileprivate func updateTripStatus() {
    var coords = [CLLocationCoordinate2D]()
    coords.append(contentsOf: updateNextStepTripStatus())
    coords.append(contentsOf: updateCurrentTripStatus())
    updateMapViewport(coords)
  }
  
  // MARK: Private
  
  /**
   * Update the current trip view
   */
  fileprivate func updateCurrentTripStatus() -> [CLLocationCoordinate2D] {
    let result = analyzer.findActiveSegments()
    currentSegmentIndex = result.index
    switch result.instruction {
    case .Waiting:
      return updateWaitingData(view: stepByStepView, segment: result.segment)
    case .Riding:
      return updateRidingData(view: stepByStepView, segment: result.segment)
    case .Walking:
      return updateWalkingData(view: stepByStepView, segment: result.segment, showDetails: nextStepView.isHidden)
    case .Arrived:
      return tripPassed(view: stepByStepView, segment: result.segment)
    }
  }
  
  /**
   * Update the next step trip view
   */
  @objc fileprivate func updateNextStepTripStatus() -> [CLLocationCoordinate2D] {
    if let result = analyzer.findNextStep(currentSegmentIndex) {
      nextStepView.isHidden = false
      switch result.instruction {
      case .Waiting:
        return updateWaitingData(view: nextStepView, segment: result.segment)
      case .Riding:
        return updateRidingData(view: nextStepView, segment: result.segment)
      case .Walking:
        return updateWalkingData(view: nextStepView, segment: result.segment, showDetails: true)
      case .Arrived:
        return tripPassed(view: nextStepView, segment: result.segment)
      }
    }
    nextStepView.isHidden = true
    return []
  }
  
  /**
   * Update UI to show waiting instructions
   */
  fileprivate func updateWaitingData(view: StepByStepView, segment: TripSegment) -> [CLLocationCoordinate2D] {
    let lineData = TripHelper.friendlyLineData(segment)
    let lineDesc = TripHelper.friendlyTripSegmentDesc(segment)
    let inAbout = createInAbout(date: segment.departureDateTime)
    
    view.nextStep.text = "Vänta på \(segment.type.decisive)"
    view.instructions.text = "\(lineData.long) \(lineDesc)"
    view.inAbout.text = "Den går \(inAbout.lowercased())"
    if let loc = segment.origin.location {
      return [loc.coordinate]
    }
    return []
  }
  
  /**
   * Update UI to show riding instructions
   */
  fileprivate func updateRidingData(view: StepByStepView, segment: TripSegment) -> [CLLocationCoordinate2D] {
    let lineData = TripHelper.friendlyLineData(segment)
    let lineDesc = TripHelper.friendlyTripSegmentDesc(segment)
    let inAbout = createInAbout(date: segment.arrivalDateTime)
    
    view.nextStep.text = "Åk till \(segment.destination.name)"
    view.instructions.text = "\(lineData.long) \(lineDesc)"
    view.inAbout.text = "Du är framme \(inAbout.lowercased())"
    return findCoordsForSegment(segment)
    
  }
  
  /**
   * Update UI to show walking instructions
   */
  fileprivate func updateWalkingData(view: StepByStepView,
                                     segment: TripSegment,
                                     showDetails: Bool) -> [CLLocationCoordinate2D] {
    view.nextStep.text = "Gå till \(segment.destination.name)"
    view.instructions.text = nil
    view.inAbout.text = nil
    if currentSegmentIndex < currentTrip!.allTripSegments.count - 1 && nextStepView.isHidden {
      let nextSegement = currentTrip!.allTripSegments[currentSegmentIndex + 1]
      let lineData = TripHelper.friendlyLineData(nextSegement)
      let lineDesc = TripHelper.friendlyTripSegmentDesc(nextSegement)
      view.instructions.text = "Där ska du ta \(lineData.long) \(lineDesc)"
    }
    return [segment.origin.location!.coordinate, segment.destination.location!.coordinate]
  }
  
  /**
   * Update UI to show riding instructions
   */
  fileprivate func tripPassed(view: StepByStepView, segment: TripSegment) -> [CLLocationCoordinate2D] {
    view.nextStep.text = "Du är framme!"
    view.instructions.text = "Vid \(segment.destination.name)"
    view.inAbout.text = nil
    return findCoordsForSegment(segment)
  }
  
  /**
   * Finds route coordinates for segment.
   */
  fileprivate func findCoordsForSegment(_ segment: TripSegment) -> [CLLocationCoordinate2D] {
    for tuple in routeTuples {
      if segment == tuple.1 {
        return tuple.0
      }
    }
    
    return []
  }
  
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
      for tuple in routeTuples {
        RoutePlotter.createOverlays(tuple.0, tuple.1, currentTrip, mapView, showStart: false)
      }
      activityIndicator.stopAnimating()
      mapView.isHidden = false
      stepByStepView.isHidden = false
      isMapLoaded = true
      startRefreshTimmer()
      updateTripStatus()
    }
  }
  
  /**
   * Create an in about text.
   */
  fileprivate func createInAbout(date: Date) -> String {
    let inAbout = DateUtils.createAboutTimeText(
      date,
      isWalk: false)
    
    if inAbout == "" {
      return DateUtils.dateAsTimeString(date)
    }
    return inAbout
  }
  
  /**
   * Updates the map viewport to displat the coordinates
   */
  fileprivate func updateMapViewport( _ coords: [CLLocationCoordinate2D]) {
    var coords = coords
    if isOverviewLocked {
      if let myCoord = MyLocationHelper.sharedInstance.getCurrentLocation(), let loc = myCoord.location {
        coords.append(loc.coordinate)
      }
      let padding = (nextStepView.isHidden) ? CGFloat(125) : CGFloat(200)
      MapHelper.setMapViewport(mapView, coordinates: coords, topPadding: padding)
    }
  }
  
  
  /**
   * Inits and prepares the map view
   */
  fileprivate func prepareMapView() {
    disableMapScroll()
    let mapPanGesture = UIPanGestureRecognizer(target: self, action: #selector(self.mapInteract(_:)))
    mapView.addGestureRecognizer(mapPanGesture)
    let mapTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.mapInteract(_:)))
    mapView.addGestureRecognizer(mapTapGesture)
    mapView.delegate = self
    mapView.mapType = MKMapType.standard
    mapView.showsBuildings = true
    mapView.showsCompass = false
    mapView.showsUserLocation = true
    mapView.showsPointsOfInterest = false
    mapView.isHidden = true
    
    var coord = CLLocationCoordinate2D()
    if let location = MyLocationHelper.sharedInstance.getCurrentLocation(), let loc = location.location {
      coord = loc.coordinate
    }
    let viewRegion = MKCoordinateRegionMakeWithDistance(coord, 1000, 1000)
    mapView.setRegion(viewRegion, animated: false)
  }
  
  /*
   * Disable map scrolling
   */
  func disableMapScroll() {
    mapView.isZoomEnabled = false
    mapView.isPitchEnabled = false
    mapView.isRotateEnabled = false
    mapView.isScrollEnabled = false
  }
  
  /*
   * Enable map scrolling
   */
  func enableMapScroll() {
    mapView.isZoomEnabled = true
    mapView.isPitchEnabled = true
    mapView.isRotateEnabled = true
    mapView.isScrollEnabled = true
  }
  
  func mapInteract(_ sender: UITapGestureRecognizer) {
    enableMapScroll()
    autoManualSegmentControl.selectedSegmentIndex = 1
    isOverviewLocked = false
  }
}
