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
  var selectedLocation: Location?
  var searchOnlyForStations = true
  var noResults = false
  var isLocationForRealTimeSearch = false
  var delegate: LocationSearchResponder?
  var searchQueryText: String?
  
  let loadedTime = NSDate()
  
  /**
   * View is done loading.
   */
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = StyleHelper.sharedInstance.background
    tableView.tableFooterView = UIView()
    edgesForExtendedLayout = UIRectEdge.None
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
    }
  }
  
  // MARK: UITableViewController
  
  /**
   * Number of rows
   */
  override func tableView(
    tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if noResults {
      return 1
    }
    return searchResult.count
  }
  
  /**
   * Cell for index
   */
  override func tableView(
    tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    if noResults {
      let cell = tableView.dequeueReusableCellWithIdentifier(
        cellNotFoundId, forIndexPath: indexPath)
      return cell
    }
    
    let location = searchResult[indexPath.row]
    return createLocationCell(indexPath, location: location)
  }
  
  /**
   * User selects row
   */
  override func tableView(
    tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    selectedLocation = searchResult[indexPath.row]
    if let loc = selectedLocation {
      LatestLocationsStore.sharedInstance.addLatestLocation(loc)
      if isLocationForRealTimeSearch {
        performSegueWithIdentifier("showRealTime", sender: self)
      } else {
        performSegueWithIdentifier("unwindToStationSearchParent", sender: self)
        delegate?.selectedLocationFromSearch(loc)
      }
    }
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
  
  // MARK: UISearchResultsUpdating
  
  @objc func updateSearchResultsForSearchController(searchController: UISearchController) {
    NSObject.cancelPreviousPerformRequestsWithTarget(
      self, selector: #selector(searchLocation), object: nil)
    searchQueryText = searchController.searchBar.text
    self.performSelector(#selector(searchLocation), withObject: nil, afterDelay: 0.3)
  }
  
  /**
   * Executes a search
   */
  func searchLocation() {
    if let query = searchQueryText {
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
              self.tableView.reloadData()
            }
          }
        }
      } else if query.characters.count == 0 {
        self.noResults = false
        self.tableView.reloadData()
      }
    }
  }
  
  // MARK: Private
  
  /**
   * Select loation at index path
   */
  private func selectLocation(indexPath: NSIndexPath) {
    selectedLocation = searchResult[indexPath.row]
  }
  
  /**
   * Create location cell.
   */
  private func createLocationCell(
    indexPath: NSIndexPath, location: Location) -> UITableViewCell {
    
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