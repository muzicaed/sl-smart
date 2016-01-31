//
//  NearbyStationsVC.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-02-01.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit
import ResStockholmApiKit

class NearbyStationsVC: UITableViewController {
  
  var delegate: LocationSearchResponder?
  var isLoading = true
  var nearbyLocations = [(location: Location, dist: Int)]()
  var isLocationForRealTimeSearch = false
  var selectedLocation: Location?
  
  @IBOutlet weak var spinnerView: UIView!
  
  override func viewDidLoad() {
    view.backgroundColor = StyleHelper.sharedInstance.background
    tableView.tableFooterView = UIView(frame: CGRectZero)
    loadLocations()
    spinnerView.frame.size = tableView.frame.size
    spinnerView.frame.origin.y -= 84
    tableView.addSubview(spinnerView)
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
  * Row count
  */
  override func tableView(tableView: UITableView,
    numberOfRowsInSection section: Int) -> Int {
      return nearbyLocations.count
  }
  
  /**
   * Cell for index
   */
  override func tableView(tableView: UITableView,
    cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      
      let locationTuple = nearbyLocations[indexPath.row]
      let cell = tableView.dequeueReusableCellWithIdentifier("NearbyStationRow",
        forIndexPath: indexPath)
      cell.textLabel?.text = "\(locationTuple.location.name)"
      cell.detailTextLabel?.text = "ca. \(locationTuple.dist) meter bort."
      cell.imageView?.alpha = 0.4
      return cell
  }
  
  /**
   * Height for row
   */
  override func tableView(tableView: UITableView,
    heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
      return 44
  }
  
  /**
   * Size for headers.
   */
  override func tableView(tableView: UITableView,
    heightForHeaderInSection section: Int) -> CGFloat {
      return 0.01
  }
  
  /**
   * Size for headers.
   */
  override func tableView(tableView: UITableView,
    heightForFooterInSection section: Int) -> CGFloat {
      return 0.01
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
  
  /**
   * User selects row
   */
  override func tableView(tableView: UITableView,
    didSelectRowAtIndexPath indexPath: NSIndexPath) {
      selectedLocation = nearbyLocations[indexPath.row].location
      LatestLocationsStore.sharedInstance.addLatestLocation(selectedLocation!)
      if isLocationForRealTimeSearch {
        performSegueWithIdentifier("showRealTime", sender: self)
      } else {
        performSegueWithIdentifier("unwindToStationSearchParent", sender: self)
        delegate?.selectedLocationFromSearch(selectedLocation!)
      }
  }
  
  // MARK: Private
  
  
  /**
  * Search for nearby locations
  */
  private func loadLocations() {
    if let currentPostion = MyLocationHelper.sharedInstance.currentLocation {
      LocationSearchService.searchNearby(currentPostion, distance: 750,
        callback: { (data, error) -> Void in
          if error != nil {
            // TODO: HANDLE ERROR!!
            return
          }
          self.nearbyLocations = data
          dispatch_async(dispatch_get_main_queue()) {
            self.isLoading = false
            self.spinnerView.removeFromSuperview()
            self.tableView.reloadData()
          }
      })
    }
  }
}