//
//  MyLocationHelper.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-27.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import CoreLocation

class MyLocationHelper: NSObject, CLLocationManagerDelegate {
  
  static let sharedInstance = MyLocationHelper()
  let locationManager = CLLocationManager()
  var currentLocation: CLLocation?
  var callback: ((CLLocation) -> Void)?
  
  override init() {
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
  func requestLocationUpdate(callback: ((location: CLLocation) -> ())?) {
    if let location = currentLocation {
        callback?(location: location)
    }
    
    self.callback = callback
  }
  
  // MARK: CLLocationManagerDelegate
  
  /**
  * On location update
  */
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
    let sortedLocations = locations.sort {$0.timestamp.timeIntervalSince1970 > $1.timestamp.timeIntervalSince1970}
    currentLocation = sortedLocations[0]
    callback?(currentLocation!)
    callback = nil
  }
  
  /**
   * On error
   */
  func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
    if error.code != 0 {
      fatalError(error.debugDescription)
    }
  }
}