//
//  MyLocationHelper.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-27.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import CoreLocation

public class MyLocationHelper: NSObject, CLLocationManagerDelegate {
  
  public  static let sharedInstance = MyLocationHelper()
  public let locationManager = CLLocationManager()
  public var currentLocation: CLLocation?
  public var callback: ((CLLocation) -> Void)?
  
  override public init() {
    super.init()
    if CLLocationManager.locationServicesEnabled() {
      locationManager.delegate = self
      locationManager.requestWhenInUseAuthorization()
      locationManager.pausesLocationUpdatesAutomatically = true
      locationManager.desiredAccuracy = 30
      locationManager.distanceFilter = 30
      locationManager.startUpdatingLocation()
    } else {
      fatalError("SignificatLoationChange not available.")
    }
  }
  
  /**
   * Request a force updat of current location.
   */
  public func requestLocationUpdate(callback: ((location: CLLocation) -> ())?) {
    if let location = currentLocation {
      callback?(location: location)
    }
    
    self.callback = callback
  }
  
  // MARK: CLLocationManagerDelegate
  
  /**
  * On location update
  */
  public func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
    let sortedLocations = locations.sort {$0.timestamp.timeIntervalSince1970 > $1.timestamp.timeIntervalSince1970}
    currentLocation = sortedLocations[0]
    callback?(currentLocation!)
    callback = nil
  }
  
  /**
   * On error
   */
  public func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
    if error.code != 0 {
      fatalError(error.debugDescription)
    }
  }
}