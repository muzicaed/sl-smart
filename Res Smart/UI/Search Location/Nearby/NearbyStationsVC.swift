//
//  NearbyStationsVC.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-02-01.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit
import ResStockholmApiKit

class NearbyStationsVC: UITableViewController {
  
  var delegate: LocationSearchResponder?
  var isLoading = true
  var nearbyLocations = [(location: Location, dist: Int)]()
  var isLocationForRealTimeSearch = false
  var selectedLocation: Location?
  
  @IBOutlet weak var spinnerView: UIView!
  @IBOutlet weak var showOnMapButton: UIBarButtonItem!
  
  /**
   * View did load
   */
  override func viewDidLoad() {
    view.backgroundColor = StyleHelper.sharedInstance.background
    tableView.tableFooterView = UIView(frame: CGRect.zero)
    loadLocations()
    spinnerView.frame.size = tableView.frame.size
    spinnerView.frame.origin.y -= 84
    tableView.addSubview(spinnerView)
  }
  
  /**
   * Before segue is performed
   */
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    if segue.identifier == "ShowRealTime" {
      if let realTimeVC = segue.destination as? RealTimeVC {
        realTimeVC.title = selectedLocation?.name
        realTimeVC.siteId = Int(selectedLocation!.siteId!)!
      }
    } else if segue.identifier == "ShowMap" {
      if let mapVC = segue.destination as? NearbyStationsMapVC {
        mapVC.nearbyLocations = nearbyLocations
        mapVC.nearbyStationsVC = self
      }
    }
  }
  
  /**
   * User selected location from map.
   */
  func selectedOnMap(_ location: Location) {
    selectedLocation = location
    performSelectedNavigation()
  }
  
  // MARK: UITableViewController
  
  /**
   * Row count
   */
  override func tableView(
    _ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return nearbyLocations.count
  }
  
  /**
   * Cell for index
   */
  override func tableView(
    _ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let locationTuple = nearbyLocations[indexPath.row]
    let cell = tableView.dequeueReusableCell(withIdentifier: "NearbyStationRow",
                                                           for: indexPath)
    cell.textLabel?.text = "\(locationTuple.location.name)"
    cell.detailTextLabel?.text = String(format: "ca. %d meter bort.".localized, locationTuple.dist)
    cell.imageView?.alpha = 0.4
    return cell
  }
  
  /**
   * Height for row
   */
  override func tableView(_ tableView: UITableView,
                          heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 44
  }
  
  /**
   * Size for headers.
   */
  override func tableView(_ tableView: UITableView,
                          heightForHeaderInSection section: Int) -> CGFloat {
    return 0.01
  }
  
  /**
   * Size for headers.
   */
  override func tableView(_ tableView: UITableView,
                          heightForFooterInSection section: Int) -> CGFloat {
    return 0.01
  }
  
  /**
   * Green highlight on selected row.
   */
  override func tableView(_ tableView: UITableView,
                          willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    let bgColorView = UIView()
    bgColorView.backgroundColor = StyleHelper.sharedInstance.highlight
    cell.selectedBackgroundView = bgColorView
  }
  
  /**
   * User selects row
   */
  override func tableView(
    _ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    selectedLocation = nearbyLocations[indexPath.row].location
    performSelectedNavigation()
  }
  
  // MARK: Private
  
  /**
   * Perform correct navigation when user select locaiton.
   */
  fileprivate func performSelectedNavigation() {
    LatestLocationsStore.sharedInstance.addLatestLocation(selectedLocation!)
    if isLocationForRealTimeSearch {
      performSegue(withIdentifier: "ShowRealTime", sender: self)
    } else {
      performSegue(withIdentifier: "unwindToStationSearchParent", sender: self)
      delegate?.selectedLocationFromSearch(selectedLocation!)
    }
  }
  
  /**
   * Search for nearby locations
   */
  fileprivate func loadLocations() {
    if let currentPostion = MyLocationHelper.sharedInstance.currentLocation {
      NetworkActivity.displayActivityIndicator(true)
      LocationSearchService.searchNearby(
        currentPostion, distance: 1000,
        callback: { (data, error) -> Void in
          DispatchQueue.main.async {
            NetworkActivity.displayActivityIndicator(false)
            if error != nil {
              self.handleLoadDataError()
              return
            }
            self.nearbyLocations = data
            
            self.isLoading = false
            self.spinnerView.removeFromSuperview()
            self.tableView.reloadData()
            self.showOnMapButton.isEnabled = true
          }          
      })
    }
  }
  
  /**
   * Hadle load data (network) error
   */
  fileprivate func handleLoadDataError() {
    let invalidLoadingAlert = UIAlertController(
      title: "Tjänsten är otillgänglig".localized,
      message: "Det gick inte att kontakta söktjänsten.".localized,
      preferredStyle: UIAlertControllerStyle.alert)
    invalidLoadingAlert.addAction(
      UIAlertAction(title: "Okej".localized, style: UIAlertActionStyle.default, handler: { _ in
        let _ = self.navigationController?.popToRootViewController(animated: false)
      }))
    
    present(invalidLoadingAlert, animated: true, completion: nil)
  }
}
