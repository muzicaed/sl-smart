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

class SearchLocationVC: UITableViewController, UISearchResultsUpdating {
  
  let cellReusableId = "StationSearchResultCell"
  let cellNotFoundId = "NoStationsFound"
  var searchController: UISearchController?
  var searchResult = [Location]()
  var delegate: LocationSearchResponder?
  var searchOnlyForStations = true
  var noResults = false
  
  /**
   * View is done loading.
   */
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = StyleHelper.sharedInstance.background
    
    self.searchController = UISearchController(searchResultsController: nil)
    self.searchController!.searchResultsUpdater = self
    self.searchController!.dimsBackgroundDuringPresentation = false
    self.searchController!.searchBar.placeholder = "Ange namnet på en station"
    
    self.tableView.tableHeaderView = self.searchController!.searchBar
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
  * Number of rows
  */
  override func tableView(tableView: UITableView,
    numberOfRowsInSection section: Int) -> Int {
      if noResults {
        return 1
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
      }
      
      let station = searchResult[indexPath.row]
      let cell = tableView.dequeueReusableCellWithIdentifier(cellReusableId,
        forIndexPath: indexPath)
      cell.textLabel?.text = station.name
      cell.detailTextLabel?.text = station.area
      if station.type == .Station {
        cell.imageView?.image = UIImage(named: "station-icon")
      } else {
        cell.imageView?.image = UIImage(named: "address-icon")
      }
      cell.imageView?.alpha = 0.4
      
      return cell
  }
  
  /**
   * User selects row
   */
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let selectedStation = searchResult[indexPath.row]
    delegate?.selectedLocationFromSearch(selectedStation)
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
    if let query = searchController.searchBar.text {
      if query.characters.count > 1 {
        self.noResults = false
        LocationSearchService.search(query, stationsOnly: searchOnlyForStations) { resTuple in
          dispatch_async(dispatch_get_main_queue(), {
            if let error = resTuple.error {
              print("\(error)")
              self.noResults = true
              self.tableView.reloadData()
              return
            }
            self.searchResult = resTuple.data
            self.tableView.reloadData()
          })
        }
      }
    }
  }
  
  // MARK: Private
  
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