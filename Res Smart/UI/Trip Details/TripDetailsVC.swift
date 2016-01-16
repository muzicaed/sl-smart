//
//  TripDetailsVC.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-12-08.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit
import ResStockholmApiKit

class TripDetailsVC: UITableViewController {
  
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var originLabel: UILabel!
  @IBOutlet weak var destinationLabel: UILabel!
  
  let originCellId = "Origin"
  let segmentCellId = "Segment"
  let subSegmentCellId = "SubSegment"
  let changeCellId = "Change"
  let destinationCellId = "Destination"
  
  var trip = Trip(durationMin: 0, noOfChanges: 0, tripSegments: [TripSegment]())
  var stopsVisual = [(isVisible: Bool, hasStops: Bool)]()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = StyleHelper.sharedInstance.background
    tableView.tableFooterView = UIView(frame: CGRect.zero)
    prepareHeader()
    prepareVisualStops()
    loadStops()
  }
  
  // MARK: UITableViewController
  
  /**
  * Number of sections
  */
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return trip.tripSegments.count + 1
  }
  
  /**
   * Number of rows in section
   */
  override func tableView(tableView: UITableView,
    numberOfRowsInSection section: Int) -> Int {
      if section == trip.tripSegments.count {
        return 1
      }
      return calculateNumberOfRows(section)
  }
  
  /**
   * Cell for index
   */
  override func tableView(tableView: UITableView,
    cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      let sec = indexPath.section
      if sec == 0 {
        return createOriginCell(indexPath)
      } else if sec == trip.tripSegments.count {
        return createDestinationCell()
      }
      
      return createSegmentCell(indexPath)
  }
  
  /**
   * Row height
   */
  override func tableView(tableView: UITableView,
    heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
      if indexPath.section == 0 {
        if indexPath.row == 0 {
          return 44
        } else if indexPath.row == 1 {
          return 60
        }
      } else if indexPath.section == trip.tripSegments.count {
        return 44
      }
      
      if indexPath.row == 0 {
        return 60
      } else if indexPath.row == 1 {
        return 60
      }
      return 25
  }
  
  /**
   * Will display row at index
   */
  override func tableView(tableView: UITableView,
    willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
      let bgColorView = UIView()
      bgColorView.backgroundColor = StyleHelper.sharedInstance.mainGreenLight
      cell.selectedBackgroundView = bgColorView
  }
  
  /**
   * On row select
   */
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if (indexPath.section == 0 && indexPath.row == 1) ||
      (indexPath.section != trip.tripSegments.count && indexPath.row == 1) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if stopsVisual[indexPath.section].hasStops {
          stopsVisual[indexPath.section].isVisible = !stopsVisual[indexPath.section].isVisible
          updateStopsToggleAnimated(indexPath.section,
            isVisible: stopsVisual[indexPath.section].isVisible)
        }
    }
  }
  
  // MARK: Private
  
  /**
  * Create table cell for origin row.
  */
  private func createOriginCell(indexPath: NSIndexPath) -> UITableViewCell {
    if indexPath.row == 0 {
      let cell = tableView.dequeueReusableCellWithIdentifier(originCellId) as! TripDetailsOriginCell
      cell.setData(indexPath, trip: trip)
      return cell
    } else if indexPath.row == 1 {
      let visual = stopsVisual[indexPath.section]
      let cell = tableView.dequeueReusableCellWithIdentifier(segmentCellId) as! TripDetailsSegmentCell
      cell.setData(indexPath, visual: visual, trip: trip)
      return cell
    }
    
    let cell = tableView.dequeueReusableCellWithIdentifier(subSegmentCellId) as! TripDetailsSubSegmentCell
    cell.setData(indexPath, trip: trip)
    return cell
  }
  
  /**
   * Create table cell for segment row.
   */
  private func createSegmentCell(indexPath: NSIndexPath) -> UITableViewCell {
    if indexPath.row == 0 {
      let cell = tableView.dequeueReusableCellWithIdentifier(changeCellId) as! TripDetailsChangeCell
      cell.setData(indexPath, trip: trip)
      return cell
    } else if indexPath.row == 1 {
      let visual = stopsVisual[indexPath.section]
      let cell = tableView.dequeueReusableCellWithIdentifier(segmentCellId) as! TripDetailsSegmentCell
      cell.setData(indexPath, visual: visual, trip: trip)
      return cell
    }
    
    let cell = tableView.dequeueReusableCellWithIdentifier(subSegmentCellId) as! TripDetailsSubSegmentCell
    cell.setData(indexPath, trip: trip)
    return cell
  }
  
  /**
   * Create table cell for segment row.
   */
  private func createDestinationCell() -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(destinationCellId) as! TripDetailsDestinationCell
    cell.setData(NSIndexPath(), trip: trip)
    return cell
  }
  
  /**
   * Calculate number of rows for a segment section
   */
  private func calculateNumberOfRows(section: Int) -> Int {
    if section < trip.tripSegments.count && stopsVisual.count > 0 {
      let visual = stopsVisual[section]
      if visual.hasStops && visual.isVisible {
        return 2 + trip.tripSegments[section].stops.count
      }
    }
    return 2
  }
  
  /**
   * Prepares the visual stops data.
   */
  private func prepareVisualStops() {
    for _ in trip.tripSegments {
      stopsVisual.append((isVisible: false, hasStops: false))
    }
  }
  
  /**
   * Load stop data
   */
  private func loadStops() {
    for (index, segment) in trip.tripSegments.enumerate() {
      if let ref = segment.journyRef {
        JournyDetailsService.fetchJournyDetails(ref) { stops, error in
          dispatch_async(dispatch_get_main_queue()) {
            segment.stops = self.filterStops(stops, segment: segment)
            self.stopsVisual[index] = (isVisible: false, hasStops: (segment.stops.count > 0))
            self.tableView.reloadData()
          }
        }
      }
    }
  }
  
  /**
   * Filter out to show only relevat
   * in between stops.
   */
  private func filterStops(stops: [Stop], segment: TripSegment) -> [Stop] {
    var filterStops = [Stop]()
    for stop in stops {
      if let stopDate = stop.depDate {
        if stopDate.timeIntervalSince1970 > segment.departureDateTime.timeIntervalSince1970
          && stopDate.timeIntervalSince1970 < segment.arrivalDateTime.timeIntervalSince1970 {
            filterStops.append(stop)
        }
      }
    }
    
    return filterStops
  }
  
  /**
   * Prepares header
   */
  private func prepareHeader() {
    timeLabel.text = DateUtils.friendlyDate(trip.tripSegments.last!.arrivalDateTime)
    originLabel.text = "Från \(trip.tripSegments.first!.origin.cleanName)"
    destinationLabel.text = "Till \(trip.tripSegments.last!.destination.cleanName)"
  }
  
  /**
   * Updates stops list on tap.
   */
  private func updateStopsToggleAnimated(section: Int, isVisible: Bool) {
    var indexPaths = [NSIndexPath]()
    for (index, _) in trip.tripSegments[section].stops.enumerate() {
      indexPaths.append(NSIndexPath(forRow: index + 2, inSection: section))
    }
    
    if isVisible {
      tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
    } else {
      tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
    }
    
    let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: section)) as! TripDetailsSegmentCell
    cell.updateStops((isVisible: isVisible, hasStops: true))
  }
}