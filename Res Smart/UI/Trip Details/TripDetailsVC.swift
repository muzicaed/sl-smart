//
//  TripDetailsVC.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-12-08.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import ResStockholmApiKit

class TripDetailsVC: UITableViewController {
  
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var originLabel: UILabel!
  @IBOutlet weak var destinationLabel: UILabel!
  @IBOutlet weak var mapButton: UIButton!
  
  let originCellId = "Origin"
  let segmentCellId = "Segment"
  let subSegmentCellId = "SubSegment"
  let destinationCellId = "Destination"
  
  var trip = Trip(durationMin: 0, noOfChanges: 0, isValid: true, tripSegments: [TripSegment]())
  var stopsVisual = [(isVisible: Bool, hasStops: Bool)]()
  
  let loadedTime = Date()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    prepareTableView()
    prepareHeader()
    prepareVisualStops()
    loadStops()
    StopEnhancer.enhance(trip)
    NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive),
                                                     name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "ShowMap" {
      let vc = segue.destination as! TripMapVC
      vc.trip = trip
    }
  }
  
  /**
   * Returned to the app.
   */
  func didBecomeActive() {
    let now = Date()
    if now.timeIntervalSince(loadedTime) > (60 * 90) { // 1.5 hour
      navigationController?.popToRootViewController(animated: false)
    }
  }
  
  /**
   * Selects this trip for current trip
   */
  @IBAction func beginTrip(_ sender: UIBarButtonItem) {
    NotificationCenter.default.post(name: Notification.Name(rawValue: "BeginTrip"), object: trip)
  }
  
  // MARK: UITableViewController
  
  /**
   * Number of sections
   */
  override func numberOfSections(in tableView: UITableView) -> Int {
    return trip.tripSegments.count
  }
  
  /**
   * Number of rows in section
   */
  override func tableView(_ tableView: UITableView,
                          numberOfRowsInSection section: Int) -> Int {
    return calculateNumberOfRows(section)
  }
  
  /**
   * Cell for index
   */
  override func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.row == 0 {
      return createOriginCell(indexPath)
    } else if indexPath.row == (calculateNumberOfRows(indexPath.section) - 1) {
      return createDestinationCell(indexPath)
    }
    return createSegmentCell(indexPath)
  }
  
  /**
   * Will display row at index
   */
  override func tableView(_ tableView: UITableView,
                          willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    let bgColorView = UIView()
    bgColorView.backgroundColor = StyleHelper.sharedInstance.highlight
    cell.selectedBackgroundView = bgColorView
  }
  
  /**
   * On row select
   */
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if (indexPath.section == 0 && indexPath.row == 1) ||
      (indexPath.section != trip.tripSegments.count && indexPath.row == 1) {
      tableView.deselectRow(at: indexPath, animated: true)
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
  fileprivate func createOriginCell(_ indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: originCellId) as! TripDetailsOriginCell
    cell.setData(indexPath, trip: trip)
    return cell
  }
  
  /**
   * Create table cell for segment row.
   */
  fileprivate func createSegmentCell(_ indexPath: IndexPath) -> UITableViewCell {
    if indexPath.row == 1 {
      let visual = stopsVisual[indexPath.section]
      let cell = tableView.dequeueReusableCell(withIdentifier: segmentCellId) as! TripDetailsSegmentCell
      cell.setData(indexPath, visual: visual, trip: trip)
      return cell
    }
    
    let cell = tableView.dequeueReusableCell(withIdentifier: subSegmentCellId) as! TripDetailsSubSegmentCell
    cell.setData(indexPath, trip: trip)
    return cell
  }
  
  /**
   * Create table cell for segment row.
   */
  fileprivate func createDestinationCell(_ indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: destinationCellId) as! TripDetailsDestinationCell
    cell.setData(indexPath, trip: trip)
    return cell
  }
  
  /**
   * Calculate number of rows for a segment section
   */
  fileprivate func calculateNumberOfRows(_ section: Int) -> Int {
    if section < trip.tripSegments.count && stopsVisual.count > 0 {
      let visual = stopsVisual[section]
      if visual.hasStops && visual.isVisible {
        return 3 + max(trip.tripSegments[section].stops.count - 2, 0)
      }
    }
    return 3
  }
  
  /**
   * Prepares the visual stops data.
   */
  fileprivate func prepareVisualStops() {
    for _ in trip.tripSegments {
      stopsVisual.append((isVisible: false, hasStops: false))
    }
  }
  
  /**
   * Load stop data
   */
  fileprivate func loadStops() {
    var loadCount = 0
    var doneCount = 0
    
    for (index, segment) in trip.tripSegments.enumerated() {
      if let ref = segment.journyRef {
        loadCount += 1
        NetworkActivity.displayActivityIndicator(true)
        JournyDetailsService.fetchJournyDetails(ref) { stops, error in
          NetworkActivity.displayActivityIndicator(false)
          segment.stops = JournyDetailsService.filterStops(stops, segment: segment)
          self.stopsVisual[index] = (isVisible: false, hasStops: (segment.stops.count > 2))
          DispatchQueue.main.async {
            self.tableView.reloadData()
          }
          doneCount += 1
          if doneCount >= loadCount {
            DispatchQueue.main.async {
              self.mapButton.isEnabled = true
            }
          }
        }
      }
    }
    if doneCount >= loadCount {
      self.mapButton.isEnabled = true
      StopEnhancer.enhance(trip)
    }
  }
  
  /**
   * Extracts relevant locations
   */
  fileprivate func extractLocations(_ locations: [CLLocation],
                                segment: TripSegment) -> [CLLocation] {
    
    var routeLocations = [CLLocation]()
    var isPloting = false
    for location in locations {
      if location.distance(from: segment.origin.location) < 5 {
        isPloting = true
      } else if location.distance(from: segment.destination.location) < 5 {
        break
      }
      
      if isPloting {
        routeLocations.append(location)
      }
    }
    return routeLocations
  }
  
  /**
   * Prepares header
   */
  fileprivate func prepareHeader() {
    timeLabel.text = DateUtils.friendlyDate(trip.tripSegments.last!.arrivalDateTime)
    originLabel.text = "Från \(trip.tripSegments.first!.origin.cleanName)"
    destinationLabel.text = "Till \(trip.tripSegments.last!.destination.cleanName)"
  }
  
  /**
   * Updates stops list on tap.
   */
  fileprivate func updateStopsToggleAnimated(_ section: Int, isVisible: Bool) {
    var indexPaths = [IndexPath]()
    for (index, _) in trip.tripSegments[section].stops.enumerated() {
      if index < (trip.tripSegments[section].stops.count - 2) {
        indexPaths.append(IndexPath(row: index + 2, section: section))
      }
    }
    
    if isVisible {
      tableView.insertRows(at: indexPaths, with: .automatic)
    } else {
      tableView.deleteRows(at: indexPaths, with: .automatic)
    }
    
    let cell = tableView.cellForRow(
      at: IndexPath(row: 1, section: section)) as! TripDetailsSegmentCell
    cell.updateStops((isVisible: isVisible, hasStops: true))
  }
  
  /**
   * Prepares this table view
   */
  fileprivate func prepareTableView() {
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 60
    view.backgroundColor = StyleHelper.sharedInstance.background
    tableView.tableFooterView = UIView(frame: CGRect.zero)
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
}
