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
  var searchController: UISearchController?
  var searchResult = [Station]()
  var delegate: StationSearchResponder?
  
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
  
  override func tableView(tableView: UITableView,
    numberOfRowsInSection section: Int) -> Int {
      return searchResult.count
  }
  
  override func tableView(tableView: UITableView,
    cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      
      let station = searchResult[indexPath.row]
      let cell = tableView.dequeueReusableCellWithIdentifier(cellReusableId,
        forIndexPath: indexPath)
      cell.textLabel?.text = station.name
      cell.detailTextLabel?.text = station.area
      
      return cell
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let selectedStation = searchResult[indexPath.row]
    delegate?.selectedStationFromSearch(selectedStation)
    searchController?.active = false
    performSegueWithIdentifier("unwindToStationSearchParent", sender: self)
  }
  
  // MARK: UISearchResultsUpdating
  
  @objc func updateSearchResultsForSearchController(searchController: UISearchController) {
    if let query = searchController.searchBar.text {
      if query.characters.count > 1 {
        StationSearchService.search(query) { resTuple in
          dispatch_async(dispatch_get_main_queue(), {
            if let error = resTuple.error {
              print("\(error)")
              self.showNetworkErrorAlert()
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