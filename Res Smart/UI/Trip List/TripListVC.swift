//
//  TripListVC.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-26.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit
import ResStockholmApiKit

class TripListVC: UITableViewController {
  
  let cellIdentifier = "TripCell"
  let pastCellIdentifier = "PassedTripCell"
  let loadingCellIdentifier = "LoadingCell"
  let loadMoreIdentifier = "LoadMoreRow"
  let noTripsFoundCell = "FoundNoTripsCell"

  let showDetailsSegue = "ShowDetails"
  
  var firstHeader: TripHeader?
  var lastFooter: TripFooter?
  var criterions: TripSearchCriterion?
  var keys = [String]()
  var trips = Dictionary<String, [Trip]>()
  var selectedTrip: Trip?
  var isLoading = true
  var isLoadingMoreBlocked = false
  var isLoadingMore = false
  var refreshTimer: NSTimer?
  var oldTripSearchCount = 0
  var headerHight = CGFloat(25)
  
  /**
   * View is done loading
   */
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = StyleHelper.sharedInstance.background
    oldTripSearchCount = criterions!.numTrips
    if trips.count == 0 {
      loadTripData(true)
    } else {
      isLoading = false
      self.tableView?.reloadData()
    }
  }
  
  /**
   * View about to appear
   */
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    isLoadingMoreBlocked = false
  }
  
  /**
   * View about to disappear
   */
  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    refreshTimer?.invalidate()
    refreshTimer = nil
  }
  
  /**
   * Refresh collection view.
   */
  func refreshUI() {
    self.tableView?.reloadData()
  }
  
  /**
   * Unwind (back) to this view.
   */
  @IBAction func unwindToTripListVC(segue: UIStoryboardSegue) {}
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    isLoadingMoreBlocked = true
    if segue.identifier == showDetailsSegue {
      let vc = segue.destinationViewController as! TripDetailsVC
      vc.trip = selectedTrip!
    }
  }
  
  // MARK: UITableViewController
  
  /**
  * Number of sections
  */
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    if isLoading || trips.count == 0 {
      print("No sections: \(1)")
      return 1
    }
    print("No sections: \(keys.count)")
    return keys.count
  }
  
  /**
   * Item count for section
   */
  override func tableView(tableView: UITableView,
    numberOfRowsInSection section: Int) -> Int {
      if isLoading || trips.count == 0 {
        print("No rows: \(1) for sec \(section)")
        return 1
      }
      
      print("No rows: \(trips[keys[section]]!.count) for sec \(section)")
      return trips[keys[section]]!.count
  }
  
  
  /**
   * Create cells for each data post.
   */
  override func tableView(tableView: UITableView,
    cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      if isLoading {
        return createLoadingTripCell(indexPath)
      } else if trips.count == 0 {
        return createNoTripsFoundCell(indexPath)
      }
      
      return createTripCell(indexPath)
  }
  
  /**
   * Size for headers.
   */
  override func tableView(tableView: UITableView,
    heightForHeaderInSection section: Int) -> CGFloat {
      if isLoading || trips.count == 0  {
        return 0
      }
      return headerHight
  }
  
  /**
   * Size for footers.
   */
  override func tableView(tableView: UITableView,
    heightForFooterInSection section: Int) -> CGFloat {
      return 0
  }
  
  /**
   * Size for rows.
   */
  override func tableView(tableView: UITableView,
    heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
      if isLoading {
        return tableView.bounds.height - 49 - 64 - 20
      }
      return 105
  }
  
  /**
   * User tapped a row.
   */
  override func tableView(tableView: UITableView,
    didSelectRowAtIndexPath indexPath: NSIndexPath) {
      let key = keys[indexPath.section]
      selectedTrip = trips[key]![indexPath.row]
      performSegueWithIdentifier(showDetailsSegue, sender: self)
  }
  
  /**
  * View for header
  */
  override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let view = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, headerHight))
    let label = UILabel(frame: CGRectMake(0, 0, tableView.frame.size.width, headerHight))
    label.font = UIFont.systemFontOfSize(12)
    label.textColor = UIColor.whiteColor()
    label.textAlignment = NSTextAlignment.Center
    
    if trips.count > 0 {
      let date = DateUtils.convertDateString("\(keys[section]) 00:00")
      label.text = DateUtils.friendlyDate(date)
    }
    
    view.addSubview(label)
    let color = StyleHelper.sharedInstance.mainGreen
    view.backgroundColor = color.colorWithAlphaComponent(0.95)
    return view
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
  
  // MARK: UIScrollViewDelegate
  
  /**
  * On scroll
  * Will check if we scrolled to bottom
  */
  override func scrollViewDidScroll(scrollView: UIScrollView) {
    if scrollView.contentSize.height > 60 {
      let bottomEdge = scrollView.contentSize.height + scrollView.contentInset.bottom - scrollView.bounds.height
      var overflow = scrollView.contentOffset.y - bottomEdge
      if scrollView.contentSize.height < scrollView.bounds.height {
        overflow =  scrollView.contentInset.top + scrollView.contentOffset.y
      }
      
      if !isLoadingMore && !isLoadingMoreBlocked {
        if overflow > 0 {
          //lastFooter?.displaySpinner(overflow / 8)
          if overflow >= 8 {
            if trips.count > 0 {
              loadMoreTrips()
            }
          }
        } else if scrollView.contentOffset.y < 0 {
          //firstHeader?.displaySpinner((scrollView.contentOffset.y / 25) * -1)
          if scrollView.contentOffset.y < -25 {
            loadEarlierTrips()
          }
        } else {
          //firstHeader?.hideSpinner()
          //lastFooter?.hideSpinner()
        }
      }
    }
  }
  
  // MARK: Private methods
  
  /**
  * Loading the trip data, and starting background
  * collection of time table data.
  */
  private func loadTripData(shouldAppend: Bool) {
    print("Load data")
    if let criterions = self.criterions {
      SearchTripService.tripSearch(criterions,
        callback: { resTuple in
          dispatch_async(dispatch_get_main_queue()) {
            if resTuple.error != nil {
              print("Error")
              self.showNetworkErrorAlert()
              self.isLoading = false
              self.tableView?.reloadData()
              return
            }
            print("Loading done.")
            self.appendToDictionary(resTuple.data, shouldAppend: shouldAppend)
            self.isLoading = false
            self.isLoadingMore = false
            self.tableView?.reloadData()
            //self.lastFooter?.hideSpinner()
            //self.firstHeader?.hideSpinner()
            self.updateDateCriterions()
            self.refreshTimer?.invalidate()
            self.refreshTimer = nil
            self.refreshTimer = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: "refreshUI", userInfo: nil, repeats: true)
          }
      })
      return
    }
    fatalError("Criterions not set in TripListVC")
  }
  
  /**
   * Load more trips when user scrolls
   * to the bottom of the list.
   */
  private func loadMoreTrips() {
    isLoadingMore = true
    //lastFooter?.displaySpinner(1.0)
    
    let trip = trips[keys.last!]!.last!
    criterions!.searchForArrival = false
    criterions!.numTrips = oldTripSearchCount
    criterions?.time = DateUtils.dateAsTimeString(
      trip.tripSegments.last!.departureDateTime.dateByAddingTimeInterval(60))
    loadTripData(true)
  }
  
  /**
   * Load earlier trips when user scrolls
   * to the top of the list.
   */
  private func loadEarlierTrips() {
    isLoadingMore = true
    firstHeader?.displaySpinner(1.0)
    
    let trip = trips[keys.first!]!.first!
    criterions?.searchForArrival = true
    criterions!.numTrips = 3
    
    let dateTuple = DateUtils.dateAsStringTuple(
      trip.tripSegments.first!.arrivalDateTime.dateByAddingTimeInterval(-60))
    criterions?.date = dateTuple.date
    criterions?.time = dateTuple.time
    
    loadTripData(false)
  }
  
  /**
   * Appends search result to dictionary
   */
  private func appendToDictionary(var tripsArr: [Trip], shouldAppend: Bool) {
    if !shouldAppend {
      tripsArr = tripsArr.reverse()
    }
    for trip in tripsArr {
      let destDateString = DateUtils.dateAsDateString(trip.tripSegments.last!.departureDateTime)
      if !keys.contains(destDateString) {
        if shouldAppend {
          keys.append(destDateString)
        } else {
          keys.insert(destDateString, atIndex: 0)
        }
        trips[destDateString] = [Trip]()
      }
      if shouldAppend {
        trips[destDateString]!.append(trip)
      } else {
        trips[destDateString]!.insert(trip, atIndex: 0)
      }
    }
  }
  
  /**
   * Checks if a day passed in the search result, and update
   * the search criterions in that case.
   */
  private func updateDateCriterions() {
    if trips.count > 0 {
      let cal = NSCalendar.currentCalendar()
      let trip = trips[keys.last!]!.last!
      
      let departDate = trip.tripSegments.last!.departureDateTime
      let departDay = cal.ordinalityOfUnit(.Day, inUnit: .Year, forDate: departDate)
      let criterionDate = DateUtils.convertDateString("\(criterions!.date!) \(criterions!.time!)")
      let criterionDay = cal.ordinalityOfUnit(.Day, inUnit: .Year, forDate: criterionDate)
      
      if departDay != criterionDay {
        criterions?.date = DateUtils.dateAsDateString(departDate)
      }
    }
  }
  
  /**
   * Create trip cell
   */
  private func createTripCell(indexPath: NSIndexPath) -> TripCell {
    let key = keys[indexPath.section]
    let trip = trips[key]![indexPath.row]
    
    if checkInPast(trip) {
      let cell = tableView!.dequeueReusableCellWithIdentifier(pastCellIdentifier,
        forIndexPath: indexPath) as! TripCell
      cell.setupData(trip)
      return cell
    }
    
    let cell = tableView!.dequeueReusableCellWithIdentifier(cellIdentifier,
      forIndexPath: indexPath) as! TripCell
    cell.setupData(trip)
    return cell
  }
  
  /**
   * Check if trip is in past.
   */
  private func checkInPast(trip: Trip) -> Bool{
    let date = trip.tripSegments.first!.departureDateTime
    return (NSDate().timeIntervalSince1970 > date.timeIntervalSince1970)
  }
  
  /**
   * Create loading trip cell
   */
  private func createLoadingTripCell(indexPath: NSIndexPath) -> UITableViewCell {
    return tableView!.dequeueReusableCellWithIdentifier(loadingCellIdentifier,
      forIndexPath: indexPath)
  }
  
  /**
   * Create "No trips found" trip cell
   */
  private func createNoTripsFoundCell(indexPath: NSIndexPath) -> UITableViewCell {
    return tableView!.dequeueReusableCellWithIdentifier(noTripsFoundCell,
      forIndexPath: indexPath)
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