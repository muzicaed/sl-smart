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
    
    public static let sharedInstance = MyLocationHelper()
    public let locationManager = CLLocationManager()
    public var currentLocation: CLLocation?
    public var currentStreet: String?
    public var callback: ((CLLocation) -> Void)?
    public var isStarted = false
    
    override public init() {
        super.init()
        locationManager.delegate = self
        locationManager.activityType = .otherNavigation
        if CLLocationManager.locationServicesEnabled() {
            if isAllowed() {
                if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
                    startLocationManager()
                } else {
                    locationManager.requestWhenInUseAuthorization()
                }
            }
        }
    }
    
    /**
     * Request a force updat of current location.
     */
    public func requestLocationUpdate(_ callback: ((_ location: CLLocation) -> ())?) {
        locationManager.requestLocation()    
        if let location = currentLocation {
            callback?(location)
            self.callback = nil
            return
        }
        
        self.callback = callback
    }
    
    public func getCurrentLocation() -> Location? {
        if let loc = currentLocation, let street = currentStreet {
            return Location(
                id: nil,
                name: street, type: "Address",
                lat: loc.coordinate.latitude,
                lon: loc.coordinate.longitude)
        }
        return nil
    }
    
    // MARK: CLLocationManagerDelegate
    
    /**
     * On location update
     */
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let sortedLocations = locations.sorted {$0.timestamp.timeIntervalSince1970 > $1.timestamp.timeIntervalSince1970}
        currentLocation = sortedLocations[0]
        callback?(currentLocation!)
        callback = nil
        updateAddressForCurrentLocation()
    }
    
    public func locationManager(
        _ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .notDetermined {
            return
        }
        
        if status == .authorizedWhenInUse && !isStarted {
            startLocationManager()
        } else if status == .denied {
            isStarted = false
        }
    }
    
    /**
     * On error
     */
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if error._code != 0 {
            isStarted = false
        }
    }
    
    /**
     * Starts the location manager
     */
    public func startLocationManager() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager.pausesLocationUpdatesAutomatically = true
            locationManager.desiredAccuracy = 25
            locationManager.distanceFilter = 25
            locationManager.startUpdatingLocation()
            isStarted = true
            return
        }
        isStarted = false
    }
    
    /**
     * Get address for current location
     */
    fileprivate func updateAddressForCurrentLocation() {
        CLGeocoder().reverseGeocodeLocation(currentLocation!) { (placemarks, error) -> Void in
            if error != nil {
                return
            }
            
            if let mark = placemarks?.first {
                if let street = mark.thoroughfare {
                    self.currentStreet = street
                } else if let sub = mark.subLocality {
                    self.currentStreet = sub
                }
                
                if self.currentStreet != nil && mark.locality != nil {
                    self.currentStreet = self.currentStreet! + ", " + mark.locality!
                }
            }
        }
    }
    
    /**
     * Checks if Location features are allowed.
     */
    fileprivate func isAllowed() -> Bool {
        return  (
            CLLocationManager.authorizationStatus() != .restricted &&
                CLLocationManager.authorizationStatus() != .denied
        )
    }
}
