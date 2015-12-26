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
  public var currentStreet: String?
  public var callback: ((CLLocation) -> Void)?
  
  override public init() {
    super.init()
    if CLLocationManager.locationServicesEnabled() {
      locationManager.delegate = self
      locationManager.requestWhenInUseAuthorization()
      locationManager.pausesLocationUpdatesAutomatically = true
      locationManager.desiredAccuracy = 10
      locationManager.distanceFilter = 5
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
  
  public func getCurrentLocation() -> Location? {
    if let loc = currentLocation, street = currentStreet {
      return Location(
        id: nil,
        name: street, type: "Address",
        lat: String(loc.coordinate.latitude),
        lon: String(loc.coordinate.longitude))
    }
    return nil
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
    updateAddressForCurrentLocation()
  }
  
  /**
   * On error
   */
  public func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
    if error.code != 0 {
      fatalError(error.debugDescription)
    }
  }
  
  /**
   * Get address for current location
   */
  private func updateAddressForCurrentLocation() {
    CLGeocoder().reverseGeocodeLocation(currentLocation!) { (placemarks, error) -> Void in
      if let err = error {
        print("Reverse geocode error: \(err.localizedDescription)")
        return
      }
      
      if let mark = placemarks?.first {
        if let street = mark.thoroughfare {
          self.currentStreet = mark.locality! + ", " + street
        } else if let sub = mark.subLocality {
          self.currentStreet = mark.locality! + ", " + sub
        }
        print(self.currentStreet)
        print("Sub: \(mark.subLocality)")
        print("St: \(mark.thoroughfare)")
      } else {
        print("Problem with the data received from geocoder")
      }
    }
  }
}