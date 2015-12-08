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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    StandardGradient.addLayer(view)    
    tableView.tableFooterView = UIView(frame: CGRect.zero)
  }
  
  // MARK: UITableViewController
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return trip.tripSegments.count + 2
  }
  
  override func tableView(tableView: UITableView,
    numberOfRowsInSection section: Int) -> Int {
      if section == 0 || section == trip.tripSegments.count + 1 {
        return 1
      }
      return 2
  }
  
  override func tableView(tableView: UITableView,
    cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      let sec = indexPath.section
      if sec == 0 {
        return createHeaderCell()
      } else if sec == 1 {
        return createOriginCell(indexPath)
      } else if sec == (trip.tripSegments.count + 1) {
        return createDestinationCell()
      }
      
      return createSegmentCell(indexPath)
  }
  
  override func tableView(tableView: UITableView,
    heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
      if !(indexPath.section == 1 && indexPath.row == 0) &&
        indexPath.section != (trip.tripSegments.count + 1) {
          return 60
      }
      
      return 44
  }
  
  // MARK: Private
  
  /**
  * Create table cell for header row.
  */
  private func createHeaderCell() -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(headerCellId) as! TripDetailsHeaderCell
    cell.setData(NSIndexPath(), trip: trip)    
    return cell
  }
  
  /**
   * Create table cell for origin row.
   */
  private func createOriginCell(indexPath: NSIndexPath) -> UITableViewCell {
    if indexPath.row == 0 {
      let cell = tableView.dequeueReusableCellWithIdentifier(originCellId) as! TripDetailsOriginCell
      cell.setData(indexPath, trip: trip)
      return cell
    } else {
      let cell = tableView.dequeueReusableCellWithIdentifier(segmentCellId) as! TripDetailsSegmentCell
      cell.setData(indexPath, trip: trip)
      return cell
    }
  }
  
  /**
   * Create table cell for segment row.
   */
  private func createSegmentCell(indexPath: NSIndexPath) -> UITableViewCell {
    if indexPath.row == 0 {
      let cell = tableView.dequeueReusableCellWithIdentifier(changeCellId) as! TripDetailsChangeCell
      cell.setData(indexPath, trip: trip)
      return cell
    } else {
      let cell = tableView.dequeueReusableCellWithIdentifier(segmentCellId) as! TripDetailsSegmentCell
      cell.setData(indexPath, trip: trip)
      return cell
    }
  }
  
  /**
   * Create table cell for segment row.
   */
  private func createDestinationCell() -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(destinationCellId) as! TripDetailsDestinationCell
    cell.setData(NSIndexPath(), trip: trip)
    return cell
  }
}