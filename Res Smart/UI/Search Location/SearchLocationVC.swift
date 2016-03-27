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

class SearchLocationVC: UITableViewController, UISearchControllerDelegate, UISearchResultsUpdating {
  
  let cellReusableId = "StationSearchResultCell"
  let cellNotFoundId = "NoStationsFound"
  var searchController: UISearchController?
  var searchResult = [Location]()
  var latestLocations = LatestLocationsStore.sharedInstance.retrieveLatestLocations()
  var delegate: LocationSearchResponder?
  var selectedLocation: Location?
  var searchOnlyForStations = true
  var noResults = false
  var isDisplayingSearchResult = false
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
    view.backgroundColor = StyleHelper.sharedInstance.background
    
    loadLatestLocations()
    prepareSearchController()
    tableView.tableHeaderView = searchController!.searchBar
    tableView.tableFooterView = UIView()
    
    if isLocationForRealTimeSearch {
      let newBackButton = UIBarButtonItem(title: "Realtid",
        style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
      self.navigationItem.backBarButtonItem = newBackButton
    }
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "didBecomeActive",
      name: UIApplicationDidBecomeActiveNotification, object: nil)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.navigationBar.translucent = false
    loadLatestLocations()
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
      loadLatestLocations()
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
    }
  }
  
  // MARK: UITableViewController
  
  /**
  * Number of section
  */
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    if !isDisplayingSearchResult && !noResults {
      return (allowCurrentPosition || allowNearbyStations) ? 2 : 1
    }
    return 1
  }
  
  /**
   * View for header
   */
  override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let view = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 30))
    let label = UILabel(frame: CGRectMake(18, 7, tableView.frame.size.width, 15))
    label.font = UIFont.systemFontOfSize(14)
    label.textColor = UIColor.whiteColor()
    label.textAlignment = NSTextAlignment.Left
    view.addSubview(label)
    let color = StyleHelper.sharedInstance.mainGreen
    view.backgroundColor = color.colorWithAlphaComponent(0.95)
    
    if isDisplayingSearchResult && searchResult.count > 0 {
      label.text = "Sökresultat"
      return view
    } else if !isDisplayingSearchResult {
      if ((allowCurrentPosition || allowNearbyStations) && section == 1) ||
        ((!allowCurrentPosition && !allowNearbyStations) && section == 0) {
          label.text = "Senast använda platser"
          return view
      }
    }
    
    return nil
  }
  
  /**
   * Size for headers.
   */
  override func tableView(tableView: UITableView,
    heightForHeaderInSection section: Int) -> CGFloat {
      if isDisplayingSearchResult && searchResult.count > 0 {
        return 30
      } else if !isDisplayingSearchResult {
        if ((allowCurrentPosition || allowNearbyStations) && section == 1) ||
          ((!allowCurrentPosition && !allowNearbyStations) && section == 0) {
            return 30
        }
      }
      return 0
  }
  
  /**
   * Size for footer.
   */
  override func tableView(tableView: UITableView,
    heightForFooterInSection section: Int) -> CGFloat {
      return 0.01
  }
  
  /**
   * Number of rows
   */
  override func tableView(tableView: UITableView,
    numberOfRowsInSection section: Int) -> Int {
      
      if noResults {
        return 1
      } else if !isDisplayingSearchResult {
        if section == 0 && (allowCurrentPosition || allowNearbyStations) {
          var count = 0
          count += (allowCurrentPosition) ? 1 : 0
          count += (allowNearbyStations) ? 1 : 0
          return count
        }
        return latestLocations.count
      }
      
      return searchResult.count
  }
  
  /**
   * Cell for index
   */
  override func tableView(tableView: UITableView,
    cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      if noResults {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellNotFoundId,
          forIndexPath: indexPath)
        return cell
      } else if !isDisplayingSearchResult {
        if indexPath.section == 0 && (allowCurrentPosition || allowNearbyStations) {
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
        }
        let location = latestLocations[indexPath.row]
        return createLocationCell(indexPath, location: location)
      }
      
      let location = searchResult[indexPath.row]
      return createLocationCell(indexPath, location: location)
  }
  
  /**
   * User selects row
   */
  override func tableView(tableView: UITableView,
    didSelectRowAtIndexPath indexPath: NSIndexPath) {
      
      if !isDisplayingSearchResult && allowNearbyStations && indexPath.section == 0 {
        if (allowCurrentPosition && indexPath.row == 1) ||
          (!allowCurrentPosition && indexPath.row == 0) {
            searchController?.active = false
            performSegueWithIdentifier("ShowNearbyStations", sender: self)
            return
        }
      }
      
      selectLocation(indexPath)
      if let loc = selectedLocation {
        searchController?.active = false
        LatestLocationsStore.sharedInstance.addLatestLocation(loc)
        if isLocationForRealTimeSearch {
          performSegueWithIdentifier("showRealTime", sender: self)
        } else {
          performSegueWithIdentifier("unwindToStationSearchParent", sender: self)
          delegate?.selectedLocationFromSearch(loc)
        }
        loadLatestLocations()
      }
  }
  
  /**
   * Green highlight on selected row.
   */
  override func tableView(tableView: UITableView,
    willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
      let bgColorView = UIView()
      bgColorView.backgroundColor = StyleHelper.sharedInstance.mainGreenLight
      cell.selectedBackgroundView = bgColorView
  }
  
  // MARK: UISearchResultsUpdating
  
  @objc func updateSearchResultsForSearchController(searchController: UISearchController) {
    NSObject.cancelPreviousPerformRequestsWithTarget(
      self, selector: Selector("searchLocation"), object: nil)
    self.performSelector(Selector("searchLocation"), withObject: nil, afterDelay: 0.3)
  }
  
  /**
   * Executes a search
   */
  func searchLocation() {
    if let query = searchController!.searchBar.text {
      if query.characters.count > 0 {
        self.noResults = false
        NetworkActivity.displayActivityIndicator(true)
        LocationSearchService.search(query, stationsOnly: searchOnlyForStations) { resTuple in
          NetworkActivity.displayActivityIndicator(false)
          dispatch_async(dispatch_get_main_queue()) {
            if resTuple.error != nil {
              self.noResults = true
              self.tableView.reloadData()
              return
            }
            self.searchResult = resTuple.data
            if resTuple.data.count > 0 {
              self.isDisplayingSearchResult = true
              self.tableView.reloadData()
            }
          }
        }
      } else if query.characters.count == 0 {
        self.isDisplayingSearchResult = false
        self.noResults = false
        self.lastCount = latestLocations.count
        self.tableView.reloadData()
      }
    }
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
      !isDisplayingSearchResult &&
      indexPath.section == 0 && indexPath.row == 0 {
        selectedLocation = MyLocationHelper.sharedInstance.getCurrentLocation()
    } else if isDisplayingSearchResult {
      selectedLocation = searchResult[indexPath.row]
    } else {
      selectedLocation = latestLocations[indexPath.row]
    }
  }
  
  /**
   * Create location cell.
   */
  private func createLocationCell(
    indexPath: NSIndexPath, location: Location) -> UITableViewCell {
      let cell = tableView.dequeueReusableCellWithIdentifier(cellReusableId,
        forIndexPath: indexPath)
      
      cell.textLabel?.text = location.name
      cell.textLabel?.text?.accessibilityLabel = location.name
      cell.detailTextLabel?.text = location.area
      cell.detailTextLabel?.accessibilityLabel = location.area
      if location.type == .Station {
        cell.imageView?.image = UIImage(named: "station-icon")
        cell.imageView?.image?.accessibilityLabel = "Station"
      } else {
        cell.imageView?.image = UIImage(named: "address-icon")
        cell.imageView?.image?.accessibilityLabel = "Adress"
      }
      cell.imageView?.alpha = 0.4
      if isLocationForRealTimeSearch {
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
      } else {
        cell.accessoryType = UITableViewCellAccessoryType.None
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
    
    let cell = tableView.dequeueReusableCellWithIdentifier(cellReusableId,
      forIndexPath: indexPath)
    
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
   * Loads list of latest selected locations.
   */
  private func loadLatestLocations() {
    if searchOnlyForStations {
      latestLocations = LatestLocationsStore.sharedInstance.retrieveLatestStationsOnly()
    } else {
      latestLocations = LatestLocationsStore.sharedInstance.retrieveLatestLocations()
    }
    lastCount = latestLocations.count
  }
  
  /**
   * Prepares search controller
   */
  private func prepareSearchController() {    
    searchController = UISearchController(searchResultsController: nil)
    searchController!.searchResultsUpdater = self
    searchController!.delegate = self
    searchController!.dimsBackgroundDuringPresentation = false
    if searchOnlyForStations {
      searchController!.searchBar.placeholder = "Skriv namnet på en station"
    } else {
      searchController!.searchBar.placeholder = "Skriv stationsnamn eller en adress"
    }
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
    if let superView = searchController?.view.superview {
      superView.removeFromSuperview()
    }
  }
}