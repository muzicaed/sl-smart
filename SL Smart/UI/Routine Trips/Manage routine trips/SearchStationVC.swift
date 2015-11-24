//
//  SearchStationVC.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-22.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit

class SearchStationVC: UITableViewController, UISearchResultsUpdating {
  
  let cellReusableId = "StationSearchResultCell"
  var searchController: UISearchController?
  var searchResult = [Station]()
  var delegate: StationSearchResponder?
  
  /**
   * View is done loading.
   */
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor(patternImage: UIImage(named: "GreenBackground")!)
    
    self.searchController = UISearchController(searchResultsController: nil)
    self.searchController!.searchResultsUpdater = self
    self.searchController!.dimsBackgroundDuringPresentation = false
    self.searchController!.searchBar.placeholder = "Ange namnet på en station"
    
    self.tableView.tableHeaderView = self.searchController!.searchBar
    self.tableView.reloadData()
  }
  
  deinit {
    if let superView = searchController?.view.superview {
      superView.removeFromSuperview()
    }
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
    performSegueWithIdentifier("unwindToEditRoutineTrip", sender: self)
  }
  
  
  
  // MARK: UISearchResultsUpdating
  
  @objc func updateSearchResultsForSearchController(searchController: UISearchController) {    
    if let query = searchController.searchBar.text {
      if query.characters.count > 1 {
        StationSearchService.sharedInstance.search(query) { stations in
          dispatch_async(dispatch_get_main_queue(), {
            self.searchResult = stations
            self.tableView.reloadData()
          })
        }
      }
    }
  }
}