//
//  TripDetailsVC.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-12-08.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit

class TripDetailsVC: UITableViewController {
  
  let headerCellId = "Header"
  let originCellId = "Origin"
  let segmentCellId = "Segment"
  let subSegmentCellId = "SubSegment"
  let changeCellId = "Change"
  let destinationCellId = "Destination"
  
  var trip = Trip(durationMin: 0, noOfChanges: 0, tripSegments: [TripSegment]())
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    print("\(trip)")
  }
  
  // MARK: UITableViewController
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return trip.tripSegments.count + 2
  }
  
  override func tableView(tableView: UITableView,
    numberOfRowsInSection section: Int) -> Int {
      if section == 1 || section == trip.tripSegments.count {
        return 1
      }
      return 2
  }
  
  override func tableView(tableView: UITableView,
    cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      let sec = indexPath.section
      if sec == 1 {
        return createHeaderCell(indexPath)
      } else if sec == 2 {
        return createOriginCell(indexPath)
      } else if sec == (trip.tripSegments.count + 2) {
        return createDestinationCell(indexPath)
      }
      
      return createSegmentCell(indexPath)
  }
  
  override func tableView(tableView: UITableView,
    heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {      
      if indexPath.row == 2 || indexPath.row == 4 {
        return 60
      } else if indexPath.row == 3 {
        return 25
      }
      
      return 44
  }
  
  // MARK: Private
  
  /**
  * Create table cell for header row.
  */
  private func createHeaderCell(indexPath: NSIndexPath) -> UITableViewCell {
    return UITableViewCell()
  }
  
  /**
   * Create table cell for origin row.
   */
  private func createOriginCell(indexPath: NSIndexPath) -> UITableViewCell {
    return UITableViewCell()
  }
  
  /**
   * Create table cell for segment row.
   */
  private func createSegmentCell(indexPath: NSIndexPath) -> UITableViewCell {
    return UITableViewCell()
  }
  
  /**
   * Create table cell for segment row.
   */
  private func createDestinationCell(indexPath: NSIndexPath) -> UITableViewCell {
    return UITableViewCell()
  }
}