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
  var searchOnlyForStations = true
  var noResults = false
  var isDisplayingSearchResult = false
  var allowCurrentPosition = false
  var lastCount = 0
  
  /**
   * View is done loading.
   */
  override func viewDidLoad() {
    super.viewDidLoad()
    MyLocationHelper.sharedInstance.requestLocationUpdate { (_) -> () in
      self.tableView.reloadData()
    }
    view.backgroundColor = StyleHelper.sharedInstance.background
    
    if searchOnlyForStations {
      latestLocations = LatestLocationsStore.sharedInstance.retrieveLatestStationsOnly()
    }
    lastCount = latestLocations.count
    
    searchController = UISearchController(searchResultsController: nil)
    searchController!.searchResultsUpdater = self
    searchController!.delegate = self
    searchController!.dimsBackgroundDuringPresentation = false
    if searchOnlyForStations {
      searchController!.searchBar.placeholder = "Skriv namnet på en station"
    } else {
      searchController!.searchBar.placeholder = "Skriv stationsnamn eller en adress"
    }
    
    tableView.tableHeaderView = searchController!.searchBar
    tableView.tableFooterView = UIView()
  }
  
  deinit {
    if let superView = searchController?.view.superview {
      superView.removeFromSuperview()
    }
  }
  
  // MARK: UITableViewController
  
  /**
  * Number of section
  */
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    if allowCurrentPosition && !isDisplayingSearchResult && !noResults {
      return 2
    }
    return 1
  }
  
  /**
   * Section titles
   */
  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if isDisplayingSearchResult && searchResult.count > 0 {
      return "Sökresultat"
    } else if !isDisplayingSearchResult {
      if (allowCurrentPosition && section == 1) || (!allowCurrentPosition && section == 0){
        return "Senaste platser"
      }
      return nil
    }
    
    return nil
  }
  
  /**
   * Number of rows
   */
  override func tableView(tableView: UITableView,
    numberOfRowsInSection section: Int) -> Int {
      
      if noResults {
        return 1
      } else if !isDisplayingSearchResult {
        if section == 0 && allowCurrentPosition {
          return 1
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
        if allowCurrentPosition && indexPath.section == 0 {
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
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    var selectedLocation: Location?
    if allowCurrentPosition &&
      !isDisplayingSearchResult &&
      indexPath.section == 0 && indexPath.row == 0 {
        selectedLocation = MyLocationHelper.sharedInstance.getCurrentLocation()
    } else if isDisplayingSearchResult {
      selectedLocation = searchResult[indexPath.row]
    } else {
      selectedLocation = latestLocations[indexPath.row]
    }
    if let loc = selectedLocation {
      LatestLocationsStore.sharedInstance.addLatestLocation(loc)
      delegate?.selectedLocationFromSearch(loc)
      searchController?.active = false
      performSegueWithIdentifier("unwindToStationSearchParent", sender: self)
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
    self.performSelector(Selector("searchLocation"), withObject: nil, afterDelay: 0.4)
  }
  
  /**
   * Executes a search
   */
  func searchLocation() {
    
    if let query = searchController!.searchBar.text {
      if query.characters.count > 0 {
        self.noResults = false
        LocationSearchService.search(query, stationsOnly: searchOnlyForStations) { resTuple in
          dispatch_async(dispatch_get_main_queue()) {
            if resTuple.error != nil {
              self.noResults = true
              self.tableView.reloadData()
              return
            }
            self.searchResult = resTuple.data
            if resTuple.data.count > 0 {
              self.reloadTableAnimated()
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
  * Create location cell.
  */
  private func createLocationCell(
    indexPath: NSIndexPath, location: Location) -> UITableViewCell {
      let cell = tableView.dequeueReusableCellWithIdentifier(cellReusableId,
        forIndexPath: indexPath)
      
      cell.textLabel?.text = location.name
      cell.detailTextLabel?.text = location.area
      if location.type == .Station {
        cell.imageView?.image = UIImage(named: "station-icon")
      } else {
        cell.imageView?.image = UIImage(named: "address-icon")
      }
      cell.imageView?.alpha = 0.4
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
   * Reloads table data animated.
   */
  private func reloadTableAnimated() {
    tableView.beginUpdates()
    if !isDisplayingSearchResult {
      isDisplayingSearchResult = true
      if allowCurrentPosition {
        tableView.deleteSections(NSIndexSet(index: 1), withRowAnimation: .Automatic)
      }
    }
    
    tableView.deleteSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
    tableView.insertSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
    
    var insIndexPaths = [NSIndexPath]()
    for i in 0..<searchResult.count {
      insIndexPaths.append(NSIndexPath(forRow: i, inSection: 0))
    }
    tableView.insertRowsAtIndexPaths(insIndexPaths, withRowAnimation: .Fade)
    
    lastCount = searchResult.count
    tableView.endUpdates()
  }
}