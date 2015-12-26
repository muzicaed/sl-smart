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
  
  /**
   * View is done loading.
   */
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = StyleHelper.sharedInstance.background
    
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
    print("Deinit: SearchLocationVC")
  }
  
  // MARK: UITableViewController
  
  /**
  * Number of section
  */
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  /**
   * Section titles
   */
  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if !isDisplayingSearchResult && latestLocations.count > 0 {
      return "Senaste platser"
    } else if searchResult.count > 0 {
      return "Sökresultat"
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
      } else if !isDisplayingSearchResult && latestLocations.count > 0 {
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
    if isDisplayingSearchResult {
      selectedLocation = searchResult[indexPath.row]
    } else {
      selectedLocation = latestLocations[indexPath.row]
    }
    LatestLocationsStore.sharedInstance.addLatestLocation(selectedLocation!)
    delegate?.selectedLocationFromSearch(selectedLocation!)
    searchController?.active = false
    performSegueWithIdentifier("unwindToStationSearchParent", sender: self)
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
      print("Search")
      if query.characters.count > 1 {
        self.noResults = false
        LocationSearchService.search(query, stationsOnly: searchOnlyForStations) { resTuple in
          dispatch_async(dispatch_get_main_queue()) {
            if let error = resTuple.error {
              print("\(error)")
              self.noResults = true
              self.tableView.reloadData()
              return
            }
            self.isDisplayingSearchResult = true
            self.searchResult = resTuple.data
            self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
          }
        }
      } else if query.characters.count == 0 {
        self.isDisplayingSearchResult = false
        self.noResults = false
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
}