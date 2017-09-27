//
//  SearchLocationVC.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-22.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit
import ResStockholmApiKit

class SearchLocationVC: UITableViewController, UISearchControllerDelegate {
  
  let cellReusableId = "StationSearchResultCell"
  let cellNotFoundId = "NoStationsFound"
  var searchController: UISearchController?
  var latestLocations = LatestLocationsStore.sharedInstance.retrieveLatestLocations()
  var favouriteLocations = FavouriteLocationsStore.sharedInstance.retrieveFavouriteLocations()
  var delegate: LocationSearchResponder?
  var selectedLocation: Location?
  var searchOnlyForStations = true
  var allowCurrentPosition = false
  var allowNearbyStations = false
  var lastCount = 0
  var isLocationForRealTimeSearch = false
  var editFavouritebutton = UIButton()  
  
  let loadedTime = Date()
  
  /**
   * View is done loading.
   */
  override func viewDidLoad() {
    super.viewDidLoad()
    MyLocationHelper.sharedInstance.requestLocationUpdate { (_) -> () in
      self.tableView.reloadData()
    }
    
    loadListedLocations()
    prepareSearchController()
    prepareEditFavouriteButton()
    tableView.tableFooterView = UIView()
    
    if isLocationForRealTimeSearch {
      let newBackButton = UIBarButtonItem(
        title: "Real time".localized, style: UIBarButtonItemStyle.plain, target: nil, action: nil)
      self.navigationItem.backBarButtonItem = newBackButton
    }
    NotificationCenter.default.addObserver(
      self, selector: #selector(didBecomeActive),
      name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.navigationBar.isTranslucent = false
    loadListedLocations()
    tableView.isEditing = false
    tableView.reloadData()
  }
  
  /**
   * Returned to the app.
   */
  @objc func didBecomeActive() {
    let now = Date()
    if now.timeIntervalSince(loadedTime) > (60 * 30) { // 0.5 hour
      let _ = navigationController?.popToRootViewController(animated: false)
    } else {
      loadListedLocations()
    }
  }
  
  /**
   * Before segue is performed
   */
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showRealTime" {
      if let realTimeVC = segue.destination as? RealTimeVC {
        if let selectedLocation = selectedLocation, let siteId = selectedLocation.siteId {
          realTimeVC.title = selectedLocation.name
          realTimeVC.siteId = Int(siteId)!
        }
      }
    } else if segue.identifier == "ShowNearbyStations" {
      if let nearbyVC = segue.destination as? NearbyStationsVC {
        
        nearbyVC.delegate = delegate
        nearbyVC.isLocationForRealTimeSearch = isLocationForRealTimeSearch
      }
    } else if segue.identifier == "ShowLocationMap" {
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
    loadListedLocations()
    self.selectedLocation = nil
    tableView.reloadData()
  }
  
  /**
   * Show selected station on map.
   */
  func showLocationOnMap(_ alertAction: UIAlertAction) {
    performSegue(withIdentifier: "ShowLocationMap", sender: self)
  }
  
  /**
   * Location wes selected on search result.
   */
  func onSearchSelectLocation(_ location: Location) {
    selectedLocation = location
    navigateOnSelect()
  }
  
  // MARK: UITableViewController
  
  /**
   * Number of section
   */
  override func numberOfSections(in tableView: UITableView) -> Int {
    let count = (allowCurrentPosition || allowNearbyStations) ? 2 : 1
    return (favouriteLocations.count > 0) ? count + 1 : count
  }
  
  /**
   * View for header
   */
  override func tableView(
    _ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    
    let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 25))
    let label = UILabel(frame: CGRect(x: 18, y: 0, width: tableView.frame.size.width, height: 25))
    label.font = UIFont.systemFont(ofSize: 14)
    label.textColor = UIColor.white
    label.textAlignment = .left
    view.addSubview(label)
    let color = UIColor.darkGray
    view.backgroundColor = color.withAlphaComponent(0.95)
    
    let topSection = (allowCurrentPosition || allowNearbyStations) ? 0 : -1
    let favSection = (favouriteLocations.count > 0) ? topSection + 1 : -1
    
    if section == topSection {
      return nil
    }
    
    if section == favSection {
      label.text = "Favourites".localized
      view.addSubview(editFavouritebutton)
      return view
    }
    
    label.text = "Recently used locations".localized
    return view
  }
  
  @objc func toggleEditFavourites() {
    tableView.isEditing = !tableView.isEditing
    let title = (tableView.isEditing) ? "Done".localized : "Change order".localized
    editFavouritebutton.setTitle(title, for: UIControlState())
    editFavouritebutton.frame = CGRect(x: tableView.frame.size.width - 118, y: 0, width: 100, height: 25)
    editFavouritebutton.contentHorizontalAlignment = .right
  }
  
  /**
   * Size for headers.
   */
  override func tableView(
    _ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    if (allowCurrentPosition || allowNearbyStations) && section == 0 {
      return 1
    }
    return 25
  }
  
  /**
   * Size for footer.
   */
  override func tableView(
    _ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 0.01
  }
  
  /**
   * Number of rows
   */
  override func tableView(
    _ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    let topSection = (allowCurrentPosition || allowNearbyStations) ? 0 : -1
    let favSection = (favouriteLocations.count > 0) ? topSection + 1 : -1
    
    if section == topSection {
      let count = (allowCurrentPosition) ? 1 : 0
      return (allowNearbyStations) ? count + 1 : count + 0
    } else if section == favSection {
      return favouriteLocations.count
    }
    
    return latestLocations.count
  }
  
  /**
   * Cell for index
   */
  override func tableView(
    _ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let topSection = (allowCurrentPosition || allowNearbyStations) ? 0 : -1
    let favSection = (favouriteLocations.count > 0) ? topSection + 1 : -1
    
    if indexPath.section == topSection {
      if allowCurrentPosition && allowNearbyStations {
        if indexPath.row == 0 {
          return createCurrentLocationCell(indexPath)
        } else if indexPath.row == 1 {
          return createNearbyStationsCell(indexPath)
        }
      } else if (allowCurrentPosition || allowNearbyStations) && indexPath.row == 0 {
        if allowCurrentPosition {
          return createCurrentLocationCell(indexPath)
        } else {
          return createNearbyStationsCell(indexPath)
        }
      }
      return createCurrentLocationCell(indexPath)
    } else if indexPath.section == favSection {
      let location = favouriteLocations[indexPath.row]
      return createLocationCell(indexPath, location: location, isFavourite: true)
    }
    
    let location = latestLocations[indexPath.row]
    return createLocationCell(indexPath, location: location, isFavourite: false)    
  }
  
  /**
   * User selects row
   */
  override func tableView(
    _ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    if allowNearbyStations && indexPath.section == 0 {
      if (allowCurrentPosition && indexPath.row == 1) ||
        (!allowCurrentPosition && indexPath.row == 0) {
        searchController!.isActive = false
        performSegue(withIdentifier: "ShowNearbyStations", sender: self)
        return
      }
    }
    
    selectLocation(indexPath)
    navigateOnSelect()
  }
  
  /**
   * User tapped accessory
   */
  override func tableView(
    _ tableView: UITableView,
    accessoryButtonTappedForRowWith indexPath: IndexPath) {
    
    selectLocation(indexPath)
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
  
  
  /**
   * Is row editable?
   */
  override func tableView(
    _ tableView: UITableView,
    canEditRowAt indexPath: IndexPath) -> Bool {
    if indexPath.section == 1 && favouriteLocations.count > 0 {
      return true
    }
    return false
  }
  
  /**
   * Is row movable?
   */
  override func tableView(
    _ tableView: UITableView,
    canMoveRowAt indexPath: IndexPath) -> Bool {
    if indexPath.section == 1 && favouriteLocations.count > 0 {
      return true
    }
    return false
  }
  
  /**
   * Should indent row?
   */
  override func tableView(
    _ tableView: UITableView,
    shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
    return false
  }
  
  /**
   * Editing style for row
   */
  override func tableView(
    _ tableView: UITableView,
    editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
    return .none
  }
  
  /**
   * Move a row
   */
  override func tableView(
    _ tableView: UITableView,
    moveRowAt sourceIndexPath: IndexPath,
                       to destinationIndexPath: IndexPath) {
    
    FavouriteLocationsStore.sharedInstance.moveFavouriteLocation(
      sourceIndexPath.row, targetIndex: destinationIndexPath.row)
    let location = favouriteLocations.remove(at: sourceIndexPath.row)
    favouriteLocations.insert(location, at: destinationIndexPath.row)
  }
  
  /**
   * Fix for broken search bar when tranlucent navbar is off.
   * TODO: Remove if future update fixes this.
   */
  func willPresentSearchController(_ searchController: UISearchController) {
    navigationController?.navigationBar.isTranslucent = true
  }
  
  /**
   * Fix for broken search bar when tranlucent navbar is off.
   * TODO: Remove if future update fixes this.
   */
  func willDismissSearchController(_ searchController: UISearchController) {
    navigationController?.navigationBar.isTranslucent = false
  }
  
  // MARK: Private
  
  /**
   * Select loation at index path
   */
  fileprivate func selectLocation(_ indexPath: IndexPath) {
    if allowCurrentPosition &&
      indexPath.section == 0 && indexPath.row == 0 {
      selectedLocation = Location.createCurrentLocation()
    } else {
      let topSection = (allowCurrentPosition || allowNearbyStations) ? 0 : -1
      let favSection = (favouriteLocations.count > 0) ? topSection + 1 : -1
      if indexPath.section == favSection {
        selectedLocation = favouriteLocations[indexPath.row]
        return
      }
      selectedLocation = latestLocations[indexPath.row]
    }
  }
  
  /**
   * Perfroms correct navigation on selected location.
   */
  fileprivate func navigateOnSelect() {
    if let loc = selectedLocation {
      searchController!.isActive = false
      if loc.type != .Current {
        LatestLocationsStore.sharedInstance.addLatestLocation(loc)
      }
      if isLocationForRealTimeSearch {
        performSegue(withIdentifier: "showRealTime", sender: self)
      } else {
        performSegue(withIdentifier: "unwindToStationSearchParent", sender: self)
        delegate?.selectedLocationFromSearch(loc)
      }
      loadListedLocations()
    }
  }
  
  /**
   * Create location cell.
   */
  fileprivate func createLocationCell(
    _ indexPath: IndexPath, location: Location, isFavourite: Bool) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(
      withIdentifier: cellReusableId, for: indexPath)
    
    cell.textLabel?.text = location.name
    cell.detailTextLabel?.text = location.area
    
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
    
    if isFavourite {
      cell.detailTextLabel?.text = "⭐ " + location.area
      cell.editingAccessoryType = cell.accessoryType
    }
    return cell
  }
  
  /**
   * Create location cell.
   */
  fileprivate func createCurrentLocationCell(_ indexPath: IndexPath) -> UITableViewCell {
    let currentLocation = MyLocationHelper.sharedInstance.getCurrentLocation()
    let cell = tableView.dequeueReusableCell(withIdentifier: cellReusableId,
                                                           for: indexPath)
    if let loc = currentLocation {
      cell.textLabel?.text = "Current location".localized
      cell.detailTextLabel?.text = "\(loc.cleanName), \(loc.area)"
    } else {
      cell.textLabel?.text = "Can not find current location".localized
      cell.detailTextLabel?.text = nil
    }
    cell.imageView?.image = UIImage(named: "current-location-icon")
    cell.imageView?.alpha = 0.4
    cell.accessoryType = UITableViewCellAccessoryType.none
    return cell
  }
  
  /**
   * Create nearby stations cell.
   */
  fileprivate func createNearbyStationsCell(_ indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(
      withIdentifier: cellReusableId, for: indexPath)
    cell.textLabel?.text = "Nearby stops".localized
    cell.detailTextLabel?.text = "Based on your current location".localized
    cell.imageView?.image = UIImage(named: "near-me-icon")
    cell.imageView?.alpha = 0.4
    cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
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
  
  /**
   * Loads listed locations (latests and favourites)
   */
  fileprivate func loadListedLocations() {
    if searchOnlyForStations {
      latestLocations = LatestLocationsStore.sharedInstance.retrieveLatestStationsOnly()
      favouriteLocations = FavouriteLocationsStore.sharedInstance.retrieveFavouriteStationsOnly()
    } else {
      latestLocations = LatestLocationsStore.sharedInstance.retrieveLatestLocations()
      favouriteLocations = FavouriteLocationsStore.sharedInstance.retrieveFavouriteLocations()
    }
    lastCount = latestLocations.count
  }
  
  /**
   * Prepares search controller
   */
  fileprivate func prepareSearchController() {
    let searchResultsVC = storyboard!.instantiateViewController(withIdentifier: "LocationSearchResult") as! SearchLocationResultsVC
    searchResultsVC.searchLocationVC = self
    searchResultsVC.searchOnlyForStations = searchOnlyForStations
    searchResultsVC.isLocationForRealTimeSearch = isLocationForRealTimeSearch
    
    searchController = UISearchController(searchResultsController: searchResultsVC)
    searchController!.searchResultsUpdater = searchResultsVC
    searchController!.delegate = self
    searchController!.dimsBackgroundDuringPresentation = true
    
    searchController!.searchBar.barStyle = .black
    searchController!.searchBar.barTintColor = UIColor.white
    
    if searchOnlyForStations {
      searchController!.searchBar.placeholder = "Type stop name".localized
    } else {
      searchController!.searchBar.placeholder = "Type stop name or address".localized
    }
    if #available(iOS 11.0, *) {
      navigationItem.hidesSearchBarWhenScrolling = false
      navigationItem.searchController = searchController
    } else {
      tableView.tableHeaderView = searchController!.searchBar
    }
  }
  
  fileprivate func prepareEditFavouriteButton() {
    editFavouritebutton = UIButton(
      frame: CGRect(x: tableView.frame.size.width - 118, y: 0, width: 100, height: 25))
    editFavouritebutton.setTitle("Change order".localized, for: UIControlState())
    editFavouritebutton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
    editFavouritebutton.contentHorizontalAlignment = .right
    editFavouritebutton.addTarget(self,
                                  action: #selector(toggleEditFavourites),
                                  for: .touchUpInside)
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
}
