//
//  SearchLocationResultsVC.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-22.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit
import ResStockholmApiKit

class SearchLocationResultsVC: UITableViewController, UISearchResultsUpdating {
  
  let cellReusableId = "StationSearchResultCell"
  let cellNotFoundId = "NoStationsFound"
  var searchResult = [Location]()
  var searchOnlyForStations = true
  var noResults = false
  var isLocationForRealTimeSearch = false
  var searchQueryText: String?
  var selectedLocation: Location?
  
  let loadedTime = Date()
  
  weak var searchLocationVC: SearchLocationVC?
  
  /**
   * View is done loading.
   */
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.tableFooterView = UIView()
    edgesForExtendedLayout = UIRectEdge()
  }
  
  /**
   * Before segue is performed
   */
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "ShowLocationMap" {
      if let mapVC = segue.destination as? LocationMapVC {
        mapVC.location = selectedLocation
      }
    }
  }
  
  /**
   * Toggle selected station as favourite station
   */
  func toggleFavouriteStation(_ alertAction: UIAlertAction) {
    if FavouriteLocationsStore.sharedInstance.isLocationFavourite(selectedLocation!) {
      FavouriteLocationsStore.sharedInstance.removeFavouriteLocation(selectedLocation!)
    } else {
      FavouriteLocationsStore.sharedInstance.addFavouriteLocation(selectedLocation!)
    }
    self.selectedLocation = nil
    reloadTableData()
  }
  
  /**
   * Show selected station on map.
   */
  func showLocationOnMap(_ alertAction: UIAlertAction) {
    performSegue(withIdentifier: "ShowLocationMap", sender: self)
  }
  
  // MARK: UITableViewController
  
  /**
   * Number of rows
   */
  override func tableView(
    _ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if noResults {
      return 1
    }
    return searchResult.count
  }
  
  /**
   * Cell for index
   */
  override func tableView(
    _ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    if noResults {
      let cell = tableView.dequeueReusableCell(
        withIdentifier: cellNotFoundId, for: indexPath)
      return cell
    }
    
    let location = searchResult[indexPath.row]
    return createLocationCell(indexPath, location: location)
  }
  
  /**
   * User selects row
   */
  override func tableView(
    _ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    searchLocationVC?.onSearchSelectLocation(searchResult[indexPath.row])
  }
  
  /**
   * User tapped accessory
   */
  override func tableView(
    _ tableView: UITableView,
    accessoryButtonTappedForRowWith indexPath: IndexPath) {
    
    selectedLocation = searchResult[indexPath.row]
    let stationOptionsAlert = UIAlertController(
      title: nil,
      message: selectedLocation!.cleanName,
      preferredStyle: .actionSheet)
    
    var favouriteTitle = "Add to favourites".localized
    if FavouriteLocationsStore.sharedInstance.isLocationFavourite(selectedLocation!) {
      favouriteTitle = "Remove from favourites".localized
    }
    
    stationOptionsAlert.addAction(
      UIAlertAction(title: favouriteTitle, style: .default, handler: toggleFavouriteStation))
    stationOptionsAlert.addAction(
      UIAlertAction(title: "Show on map".localized, style: .default, handler: showLocationOnMap))
    stationOptionsAlert.addAction(
      UIAlertAction(title: "Cancel".localized, style: .cancel, handler: { _ in
        self.selectedLocation = nil
      }))
    
    present(stationOptionsAlert, animated: true, completion: nil)
  }
  
  /**
   * Green highlight on selected row.
   */
  override func tableView(
    _ tableView: UITableView, willDisplay cell: UITableViewCell,
    forRowAt indexPath: IndexPath) {
    
    let bgColorView = UIView()
    bgColorView.backgroundColor = StyleHelper.sharedInstance.highlight
    cell.selectedBackgroundView = bgColorView
  }
  
  // MARK: UISearchResultsUpdating
  
  @objc func updateSearchResults(for searchController: UISearchController) {
    NSObject.cancelPreviousPerformRequests(
      withTarget: self, selector: #selector(searchLocation), object: nil)
    searchQueryText = searchController.searchBar.text
    self.perform(#selector(searchLocation), with: nil, afterDelay: 0.3)
  }
  
  /**
   * Executes a search
   */
  @objc func searchLocation() {
    if let query = searchQueryText {
      if query.characters.count > 0 {
        self.noResults = false
        NetworkActivity.displayActivityIndicator(true)
        LocationSearchService.search(query, stationsOnly: searchOnlyForStations) { (locations, slNetworkError) in
          NetworkActivity.displayActivityIndicator(false)
          DispatchQueue.main.async {
            if slNetworkError != nil {
              self.noResults = true
              self.reloadTableData()
              return
            }
            self.searchResult = locations            
            if locations.count > 0 {
              self.reloadTableData()
            }
          }
        }
      } else if query.characters.count == 0 {
        self.noResults = false
        reloadTableData()
      }
    }
  }
  
  // MARK: Private
  
  /**
   * Create location cell.
   */
  fileprivate func createLocationCell(
    _ indexPath: IndexPath, location: Location) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(
      withIdentifier: cellReusableId, for: indexPath)
    
    cell.textLabel?.text = location.name
    cell.detailTextLabel?.text = location.area
    if FavouriteLocationsStore.sharedInstance.isLocationFavourite(location) {
      cell.detailTextLabel?.text = "⭐ " + location.area
    }
    if location.type == .Station {
      cell.imageView?.image = UIImage(named: "station-icon")
    } else {
      cell.imageView?.image = UIImage(named: "address-icon")
    }
    cell.imageView?.alpha = 0.4
    if isLocationForRealTimeSearch {
      cell.accessoryType = UITableViewCellAccessoryType.detailDisclosureButton
    } else {
      cell.accessoryType = UITableViewCellAccessoryType.detailButton
    }
    return cell
  }
  
  /**
   * Show a network error alert
   */
  fileprivate func showNetworkErrorAlert() {
    let networkErrorAlert = UIAlertController(
      title: "Service unavailable".localized,
      message: "Could not reach the search service.".localized,
      preferredStyle: UIAlertControllerStyle.alert)
    networkErrorAlert.addAction(
      UIAlertAction(title: "OK".localized, style: UIAlertActionStyle.default, handler: nil))
    
    present(networkErrorAlert, animated: true, completion: nil)
  }
  
  fileprivate func reloadTableData() {
    UIView.transition(with: self.tableView,
                      duration: 0.2,
                      options: .transitionCrossDissolve,
                      animations: { self.tableView?.reloadData() })
  }
}
