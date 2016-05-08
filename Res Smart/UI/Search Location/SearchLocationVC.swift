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
  
  let loadedTime = NSDate()
  
  /**
   * View is done loading.
   */
  override func viewDidLoad() {
    super.viewDidLoad()
    MyLocationHelper.sharedInstance.requestLocationUpdate { (_) -> () in
      self.tableView.reloadData()
    }
    tableView.editing = true
    view.backgroundColor = StyleHelper.sharedInstance.background
    
    loadListedLocations()
    prepareSearchController()
    tableView.tableFooterView = UIView()
    
    if isLocationForRealTimeSearch {
      let newBackButton = UIBarButtonItem(
        title: "Realtid", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
      self.navigationItem.backBarButtonItem = newBackButton
    }
    NSNotificationCenter.defaultCenter().addObserver(
      self, selector: #selector(didBecomeActive),
      name: UIApplicationDidBecomeActiveNotification, object: nil)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.navigationBar.translucent = false
    loadListedLocations()
    tableView.reloadData()
  }
  
  /**
   * Returned to the app.
   */
  func didBecomeActive() {
    let now = NSDate()
    if now.timeIntervalSinceDate(loadedTime) > (60 * 30) { // 0.5 hour
      navigationController?.popToRootViewControllerAnimated(false)
    } else {
      loadListedLocations()
    }
  }
  
  /**
   * Before segue is performed
   */
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "showRealTime" {
      if let realTimeVC = segue.destinationViewController as? RealTimeVC {
        realTimeVC.title = selectedLocation?.name
        realTimeVC.siteId = Int(selectedLocation!.siteId!)!
      }
    } else if segue.identifier == "ShowNearbyStations" {
      if let nearbyVC = segue.destinationViewController as? NearbyStationsVC {

        nearbyVC.delegate = delegate
        nearbyVC.isLocationForRealTimeSearch = isLocationForRealTimeSearch
      }
    } else if segue.identifier == "ShowLocationMap" {
      if let mapVC = segue.destinationViewController as? LocationMapVC {
        mapVC.location = selectedLocation
      }
    }
  }
  
  /**
   * Toggle selected station as favourite station
   */
  func toggleFavouriteStation(alertAction: UIAlertAction) {
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
  func showLocationOnMap(alertAction: UIAlertAction) {
    performSegueWithIdentifier("ShowLocationMap", sender: self)
  }
  
  /**
   * Location wes selected on search result.
   */
  func onSearchSelectLocation(location: Location) {
    selectedLocation = location
    navigateOnSelect()
  }
  
  // MARK: UITableViewController
  
  /**
   * Number of section
   */
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    let count = (allowCurrentPosition || allowNearbyStations) ? 2 : 1
    return (favouriteLocations.count > 0) ? count + 1 : count
  }
  
  /**
   * View for header
   */
  override func tableView(
    tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    
    let view = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 20))
    let label = UILabel(frame: CGRectMake(18, 2, tableView.frame.size.width, 15))
    label.font = UIFont.systemFontOfSize(14)
    label.textColor = UIColor.whiteColor()
    label.textAlignment = NSTextAlignment.Left
    view.addSubview(label)
    let color = StyleHelper.sharedInstance.mainGreen
    view.backgroundColor = color.colorWithAlphaComponent(0.95)
    
    let topSection = (allowCurrentPosition || allowNearbyStations) ? 0 : -1
    let favSection = (favouriteLocations.count > 0) ? topSection + 1 : -1
    
    if section == favSection {
      label.text = "Favoritplatser"
      return view
    }
    
    label.text = "Senast använda platser"
    return view
  }
  
  /**
   * Size for headers.
   */
  override func tableView(
    tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    if (allowCurrentPosition || allowNearbyStations) && section == 0 {
      return 0
    }
    return 20
  }
  
  /**
   * Size for footer.
   */
  override func tableView(
    tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 0.01
  }
  
  /**
   * Number of rows
   */
  override func tableView(
    tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
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
    tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
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
    tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    if allowNearbyStations && indexPath.section == 0 {
      if (allowCurrentPosition && indexPath.row == 1) ||
        (!allowCurrentPosition && indexPath.row == 0) {
        searchController!.active = false
        performSegueWithIdentifier("ShowNearbyStations", sender: self)
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
    tableView: UITableView,
    accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
    
    selectLocation(indexPath)
    let stationOptionsAlert = UIAlertController(
      title: nil,
      message: selectedLocation!.cleanName,
      preferredStyle: .ActionSheet)
    
    var favouriteTitle = "Gör till favorit"
    if FavouriteLocationsStore.sharedInstance.isLocationFavourite(selectedLocation!) {
      favouriteTitle = "Ta bort från favoriter"
    }
    
    stationOptionsAlert.addAction(
      UIAlertAction(title: favouriteTitle, style: .Default, handler: toggleFavouriteStation))
    stationOptionsAlert.addAction(
      UIAlertAction(title: "Visa på karta", style: .Default, handler: showLocationOnMap))
    stationOptionsAlert.addAction(
      UIAlertAction(title: "Avbryt", style: .Cancel, handler: { _ in
        self.selectedLocation = nil
      }))
    
    presentViewController(stationOptionsAlert, animated: true, completion: nil)
  }
  
  /**
   * Green highlight on selected row.
   */
  override func tableView(
    tableView: UITableView, willDisplayCell cell: UITableViewCell,
    forRowAtIndexPath indexPath: NSIndexPath) {
    
    let bgColorView = UIView()
    bgColorView.backgroundColor = StyleHelper.sharedInstance.highlight
    cell.selectedBackgroundView = bgColorView
  }
  
  
  /**
   * Is row editable?
   */
  override func tableView(
    tableView: UITableView,
    canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    if indexPath.section == 1 && favouriteLocations.count > 0 {
      return true
    }
    return false
  }
  
  /**
   * Is row movable?
   */
  override func tableView(
    tableView: UITableView,
    canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    if indexPath.section == 1 && favouriteLocations.count > 0 {
      return true
    }
    return false
  }
  
  /**
   * Should indent row?
   */
  override func tableView(
    tableView: UITableView,
    shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return false
  }

  /**
   * Editing style for row
  */
  override func tableView(
    tableView: UITableView,
    editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
    return .None
  }
  
  /**
   * Move a row
   */
  override func tableView(
    tableView: UITableView,
    moveRowAtIndexPath sourceIndexPath: NSIndexPath,
                       toIndexPath destinationIndexPath: NSIndexPath) {
    
    FavouriteLocationsStore.sharedInstance.moveFavouriteLocation(
      sourceIndexPath.row, targetIndex: destinationIndexPath.row)
    let location = favouriteLocations.removeAtIndex(sourceIndexPath.row)
    favouriteLocations.insert(location, atIndex: destinationIndexPath.row)
  }
  
  /**
   * Fix for broken search bar when tranlucent navbar is off.
   * TODO: Remove if future update fixes this.
   */
  func willPresentSearchController(searchController: UISearchController) {
    navigationController?.navigationBar.translucent = true
  }
  
  /**
   * Fix for broken search bar when tranlucent navbar is off.
   * TODO: Remove if future update fixes this.
   */
  func willDismissSearchController(searchController: UISearchController) {
    navigationController?.navigationBar.translucent = false
  }
  
  // MARK: Private
  
  /**
   * Select loation at index path
   */
  private func selectLocation(indexPath: NSIndexPath) {
    if allowCurrentPosition &&
      indexPath.section == 0 && indexPath.row == 0 {
      selectedLocation = MyLocationHelper.sharedInstance.getCurrentLocation()
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
  private func navigateOnSelect() {
    if let loc = selectedLocation {
      searchController!.active = false
      LatestLocationsStore.sharedInstance.addLatestLocation(loc)
      if isLocationForRealTimeSearch {
        performSegueWithIdentifier("showRealTime", sender: self)
      } else {
        performSegueWithIdentifier("unwindToStationSearchParent", sender: self)
        delegate?.selectedLocationFromSearch(loc)
      }
      loadListedLocations()
    }
  }
  
  /**
   * Create location cell.
   */
  private func createLocationCell(
    indexPath: NSIndexPath, location: Location, isFavourite: Bool) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCellWithIdentifier(
      cellReusableId, forIndexPath: indexPath)
    
    cell.textLabel?.text = location.name
    cell.detailTextLabel?.text = location.area
    
    if location.type == .Station {
      cell.imageView?.image = UIImage(named: "station-icon")
    } else {
      cell.imageView?.image = UIImage(named: "address-icon")
    }
    cell.imageView?.alpha = 0.4
    if isLocationForRealTimeSearch {
      cell.accessoryType = UITableViewCellAccessoryType.DetailDisclosureButton
    } else {
      cell.accessoryType = UITableViewCellAccessoryType.DetailButton
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
  private func createCurrentLocationCell(indexPath: NSIndexPath) -> UITableViewCell {
    let currentLocation = MyLocationHelper.sharedInstance.getCurrentLocation()
    let cell = tableView.dequeueReusableCellWithIdentifier(cellReusableId,
                                                           forIndexPath: indexPath)
    if let loc = currentLocation {
      cell.textLabel?.text = "Nuvarande plats"
      cell.detailTextLabel?.text = "\(loc.cleanName), \(loc.area)"
    } else {
      cell.textLabel?.text = "Hittar inte nuvarande plats"
      cell.detailTextLabel?.text = nil
    }
    cell.imageView?.image = UIImage(named: "current-location-icon")
    cell.imageView?.alpha = 0.4
    cell.accessoryType = UITableViewCellAccessoryType.None
    return cell
  }
  
  /**
   * Create nearby stations cell.
   */
  private func createNearbyStationsCell(indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(
      cellReusableId, forIndexPath: indexPath)
    cell.textLabel?.text = "Hållplatser nära mig"
    cell.detailTextLabel?.text = nil
    cell.imageView?.image = UIImage(named: "near-me-icon")
    cell.imageView?.alpha = 0.4
    cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
    return cell
  }
  
  /**
   * Show a network error alert
   */
  private func showNetworkErrorAlert() {
    let networkErrorAlert = UIAlertController(
      title: "Tjänsten är otillgänglig",
      message: "Det gick inte att kontakta söktjänsten.",
      preferredStyle: UIAlertControllerStyle.Alert)
    networkErrorAlert.addAction(
      UIAlertAction(title: "Okej", style: UIAlertActionStyle.Default, handler: nil))
    
    presentViewController(networkErrorAlert, animated: true, completion: nil)
  }
  
  /**
   * Loads listed locations (latests and favourites)
   */
  private func loadListedLocations() {
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
  private func prepareSearchController() {
    let searchResultsVC = storyboard!.instantiateViewControllerWithIdentifier("LocationSearchResult") as! SearchLocationResultsVC
    searchResultsVC.delegate = self.delegate
    searchResultsVC.searchLocationVC = self
    searchResultsVC.searchOnlyForStations = searchOnlyForStations
    searchResultsVC.isLocationForRealTimeSearch = isLocationForRealTimeSearch
    
    searchController = UISearchController(searchResultsController: searchResultsVC)
    searchController!.searchResultsUpdater = searchResultsVC
    searchController!.delegate = self
    searchController!.dimsBackgroundDuringPresentation = true
    if searchOnlyForStations {
      searchController!.searchBar.placeholder = "Skriv namnet på en station"
    } else {
      searchController!.searchBar.placeholder = "Skriv stationsnamn eller en adress"
    }
    tableView.tableHeaderView = searchController!.searchBar
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
    if let superView = searchController!.view.superview {
      superView.removeFromSuperview()
    }
  }
}