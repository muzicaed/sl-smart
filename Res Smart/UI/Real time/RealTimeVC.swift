//
//  RealTimeVC.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-01-19.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit
import ResStockholmApiKit

/**
 * TODO: This VC could use a lot of refactoring...
 */
class RealTimeVC: UITableViewController, SMSegmentViewDelegate {
  
  @IBOutlet weak var topView: UIView!
  @IBOutlet var spinnerView: UIView!
  
  var realTimeDepartures: RealTimeDepartures?
  var isLoading = true
  var firstTimeLoad = true
  var siteId = 0
  var lastSelected = 0
  var busKeys = [String]()
  var metroGreenKeys = [String]()
  var metroRedKeys = [String]()
  var metroBlueKeys = [String]()
  var trainKeys = [String]()
  var tramKeys = [String]()
  var localTramKeys = [String]()
  var boatKeys = [String]()
  
  var tabTypesKeys = [String]()
  var segmentView = SMSegmentView()
  var realtimeIndicatorLabel: UILabel?
  var refreshTimmer: NSTimer?
  let loadedTime = NSDate()
  
  /**
   * On load
   */
  override func viewDidLoad() {
    tableView.tableFooterView = UIView()
    view.backgroundColor = StyleHelper.sharedInstance.background
    spinnerView.frame.size = tableView.frame.size
    spinnerView.frame.origin.y -= 84
    tableView.addSubview(spinnerView)
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "didBecomeActive",
      name: UIApplicationDidBecomeActiveNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "didBecomeInactive",
      name: UIApplicationWillResignActiveNotification, object: nil)
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 44
    
    prepareRealtimeIndicator()
  }
  
  /**
   * View will appear
   */
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    loadData()
    startRefreshTimmer()
  }
  
  /**
   * View did unload
   */
  override func viewWillDisappear(animated: Bool) {
    super.viewDidDisappear(animated)
    stopRefreshTimmer()
  }
  
  /**
   * Returned to the app.
   */
  func didBecomeActive() {
    let now = NSDate()
    if now.timeIntervalSinceDate(loadedTime) > (60 * 30) { // 0.5 hour
      navigationController?.popToRootViewControllerAnimated(false)
      return
    }
    loadData()
    startRefreshTimmer()
  }
  
  /**
   * Backgrounded.
   */
  func didBecomeInactive() {
    stopRefreshTimmer()
  }
  
  /**
   * Starts the refresh timmer
   */
  func startRefreshTimmer() {
    stopRefreshTimmer()
    refreshTimmer = NSTimer.scheduledTimerWithTimeInterval(
      15.0, target: self, selector: Selector("loadData"), userInfo: nil, repeats: true)
  }
  
  /**
   * Stop the refresh timmer
   */
  func stopRefreshTimmer() {
    refreshTimmer?.invalidate()
    refreshTimmer = nil
  }
  
  /**
   * Load real time data
   */
  func loadData() {
    RealTimeDeparturesService.fetch(siteId) { (rtDepartures, error) -> Void in
      if error == nil {
        if let departures = rtDepartures {
          dispatch_async(dispatch_get_main_queue(), {
            self.spinnerView.removeFromSuperview()
            self.isLoading = false
            self.firstTimeLoad = false
            self.realTimeDepartures = departures
            self.setupKeys()
            self.prepareSegmentView()
            self.tableView.reloadData()
          })
        }
      }
    }
  }
  
  // MARK: UITableViewController
  
  /**
  * Section count
  */
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    if isLoading {
      return 0
    }
    
    return calcSectionCount()
  }
  
  /**
   * Row count
   */
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if isLoading {
      return 0
    }
    
    return calcRowCount(section)
  }
  
  /**
   * Cell on index
   */
  override func tableView(tableView: UITableView,
    cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      if indexPath.row == 0  {
        if tabTypesKeys.count == 0 {
          return createNotFoundCell(indexPath)
        }
        return createHeaderCell(indexPath)
      }
      
      return createBussTripCell(indexPath)
  }
  
  /**
   * Size for rows.
   */
  override func tableView(tableView: UITableView,
    heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
      if isLoading {
        return tableView.bounds.height - 49 - 64 - 20 + 39
      }
      return -1
  }
  
  // MARK: SMSegmentViewDelegate
  
  func segmentView(segmentView: SMBasicSegmentView, didSelectSegmentAtIndex index: Int) {
    lastSelected = index
    tableView.reloadData()
  }
  
  // MARK: Private
  
  /**
  * Prepares Segment View
  */
  private func prepareSegmentView() {
    segmentView.removeFromSuperview()
    segmentView = SMSegmentView(
      frame: CGRect(x: 0, y: 0, width: 100.0, height: (firstTimeLoad) ? 0 : 44),
      separatorColour: UIColor.clearColor(),
      separatorWidth: 0.0,
      segmentProperties: [
        keySegmentTitleFont: UIFont.systemFontOfSize(12.0),
        keySegmentOnSelectionColour: StyleHelper.sharedInstance.mainGreenLight,
        keySegmentOffSelectionColour: UIColor.clearColor(),
        keyContentVerticalMargin: 10.0])
    
    var tabCount = 0
    if realTimeDepartures?.busses.count > 0 {
      tabCount++
      tabTypesKeys.append("BUS")
      segmentView.addSegmentWithTitle(nil,
        onSelectionImage: UIImage(named: "BUS-NEUTRAL"),
        offSelectionImage: UIImage(named: "BUS-NEUTRAL"))
    }
    if realTimeDepartures?.greenMetros.count > 0 {
      tabCount++
      tabTypesKeys.append("METRO-GREEN")
      segmentView.addSegmentWithTitle(nil,
        onSelectionImage: UIImage(named: "METRO-GREEN"),
        offSelectionImage: UIImage(named: "METRO-GREEN"))
    }
    if realTimeDepartures?.redMetros.count > 0 {
      tabCount++
      tabTypesKeys.append("METRO-RED")
      segmentView.addSegmentWithTitle(nil,
        onSelectionImage: UIImage(named: "METRO-RED"),
        offSelectionImage: UIImage(named: "METRO-RED"))
    }
    if realTimeDepartures?.blueMetros.count > 0 {
      tabCount++
      tabTypesKeys.append("METRO-BLUE")
      segmentView.addSegmentWithTitle(nil,
        onSelectionImage: UIImage(named: "METRO-BLUE"),
        offSelectionImage: UIImage(named: "METRO-BLUE"))
    }
    if realTimeDepartures?.trains.count > 0 {
      tabCount++
      tabTypesKeys.append("TRAIN")
      segmentView.addSegmentWithTitle(nil,
        onSelectionImage: UIImage(named: "TRAIN-NEUTRAL"),
        offSelectionImage: UIImage(named: "TRAIN-NEUTRAL"))
    }
    if realTimeDepartures?.trams.count > 0 {
      tabCount++
      tabTypesKeys.append("TRAM")
      segmentView.addSegmentWithTitle(nil,
        onSelectionImage: UIImage(named: "TRAM-RAIL"),
        offSelectionImage: UIImage(named: "TRAM-RAIL"))
    }
    if realTimeDepartures?.localTrams.count > 0 {
      tabCount++
      tabTypesKeys.append("LOCAL-TRAM")
      segmentView.addSegmentWithTitle(nil,
        onSelectionImage: UIImage(named: "TRAM-LOCAL"),
        offSelectionImage: UIImage(named: "TRAM-LOCAL"))
    }
    if realTimeDepartures?.boats.count > 0 {
      tabCount++
      tabTypesKeys.append("BOAT")
      segmentView.addSegmentWithTitle(nil,
        onSelectionImage: UIImage(named: "SHIP-NEUTRAL"),
        offSelectionImage: UIImage(named: "SHIP-NEUTRAL"))
    }
    
    if tabCount > 0 {
      segmentView.delegate = self
      segmentView.selectSegmentAtIndex(lastSelected)
      segmentView.frame.size.width = CGFloat(50 * tabCount)
      topView.addSubview(segmentView)
      if firstTimeLoad {
        UIView.animateWithDuration(0.4, animations: {
          self.segmentView.frame.size.height = 44
        })
      }
    }
  }
  
  /**
   * Prepares a blinking realtime idicator.
   */
  private func prepareRealtimeIndicator() {
    realtimeIndicatorLabel?.layer.removeAllAnimations()
    realtimeIndicatorLabel?.removeFromSuperview()
    let screenWidth = UIScreen.mainScreen().bounds.width
    realtimeIndicatorLabel = UILabel(frame: CGRect(x: screenWidth - 78, y: 0, width: 70, height: 44))
    realtimeIndicatorLabel!.text = "Uppdateras i realtid"
    realtimeIndicatorLabel!.numberOfLines = 2
    realtimeIndicatorLabel!.textAlignment = NSTextAlignment.Right
    realtimeIndicatorLabel!.font = UIFont.systemFontOfSize(12)
    realtimeIndicatorLabel!.textColor = StyleHelper.sharedInstance.mainGreen
    
    topView.addSubview(realtimeIndicatorLabel!)
  }
  
  /**
   * Create header cell
   */
  private func createHeaderCell(indexPath: NSIndexPath) -> RealTimeHeaderRow {
    let cell = tableView!.dequeueReusableCellWithIdentifier("Header",
      forIndexPath: indexPath) as! RealTimeHeaderRow
    
    setHeaderData(cell, indexPath: indexPath)
    return cell
  }
  
  /**
   * Create header cell
   */
  private func createBussTripCell(indexPath: NSIndexPath) -> RealTimeTripRow {
    let cell = tableView!.dequeueReusableCellWithIdentifier("TripRow",
      forIndexPath: indexPath) as! RealTimeTripRow
    
    setRowData(cell, indexPath: indexPath)
    return cell
  }
  
  /**
   * Create not found cell
   */
  private func createNotFoundCell(indexPath: NSIndexPath) -> UITableViewCell {
    return tableView!.dequeueReusableCellWithIdentifier("NotFoundRow",
      forIndexPath: indexPath)
  }
  
  /**
   * Setup key arrays
   */
  private func setupKeys() {
    busKeys = [String]()
    metroGreenKeys = [String]()
    for (index, _) in realTimeDepartures!.busses {
      busKeys.append(index)
    }
    for (index, _) in realTimeDepartures!.greenMetros {
      metroGreenKeys.append(index)
    }
    for (index, _) in realTimeDepartures!.redMetros {
      metroRedKeys.append(index)
    }
    for (index, _) in realTimeDepartures!.blueMetros {
      metroBlueKeys.append(index)
    }
    for (index, _) in realTimeDepartures!.trains {
      trainKeys.append(index)
    }
    for (index, _) in realTimeDepartures!.trams {
      tramKeys.append(index)
    }
    for (index, _) in realTimeDepartures!.localTrams {
      localTramKeys.append(index)
    }
    for (index, _) in realTimeDepartures!.boats {
      boatKeys.append(index)
    }
  }
  
  /**
   * Calculates the needed sections.
   */
  private func calcSectionCount() -> Int {
    if tabTypesKeys.count == 0 {
      return 1
    }
    
    let tabKeys = tabTypesKeys[segmentView.indexOfSelectedSegment]
    switch tabKeys {
    case "BUS":
      return realTimeDepartures!.busses.count
    case "METRO-GREEN":
      return realTimeDepartures!.greenMetros.count
    case "METRO-RED":
      return realTimeDepartures!.redMetros.count
    case "METRO-BLUE":
      return realTimeDepartures!.blueMetros.count
    case "TRAIN":
      return realTimeDepartures!.trains.count
    case "TRAM":
      return realTimeDepartures!.trams.count
    case "LOCAL-TRAM":
      return realTimeDepartures!.localTrams.count
    case "BOAT":
      return realTimeDepartures!.boats.count
    default:
      return 0
    }
  }
  
  /**
   * Calculates the needed rows.
   */
  private func calcRowCount(section: Int) -> Int {
    if tabTypesKeys.count == 0 {
      return 1
    }
    
    let tabKeys = tabTypesKeys[segmentView.indexOfSelectedSegment]
    switch tabKeys {
    case "BUS":
      return min(realTimeDepartures!.busses[busKeys[section]]!.count + 1, 12)
    case "METRO-GREEN":
      return min(realTimeDepartures!.greenMetros[metroGreenKeys[section]]!.count + 1, 5)
    case "METRO-RED":
      return min(realTimeDepartures!.redMetros[metroRedKeys[section]]!.count + 1, 5)
    case "METRO-BLUE":
      return min(realTimeDepartures!.blueMetros[metroBlueKeys[section]]!.count + 1, 5)
    case "TRAIN":
      return min(realTimeDepartures!.trains[trainKeys[section]]!.count + 1, 5)
    case "TRAM":
      return min(realTimeDepartures!.trams[tramKeys[section]]!.count + 1, 5)
    case "LOCAL-TRAM":
      return min(realTimeDepartures!.localTrams[localTramKeys[section]]!.count + 1, 5)
    case "BOAT":
      return min(realTimeDepartures!.boats[boatKeys[section]]!.count + 1, 5)
    default:
      return 0
    }
  }
  
  /**
   * Set header cell data
   */
  private func setHeaderData(cell: RealTimeHeaderRow, indexPath: NSIndexPath) {
    let tabKeys = tabTypesKeys[segmentView.indexOfSelectedSegment]
    switch tabKeys {
    case "BUS":
      let bus = realTimeDepartures!.busses[busKeys[indexPath.section]]!.first!
      cell.icon.image = UIImage(named: "BUS-NEUTRAL")
      cell.titleLabel.text = "\(bus.stopAreaName)"
    case "METRO-GREEN":
      cell.icon.image = UIImage(named: "METRO-GREEN")
      cell.titleLabel.text = "Tunnelbanans gröna linje"
    case "METRO-RED":
      cell.icon.image = UIImage(named: "METRO-RED")
      cell.titleLabel.text = "Tunnelbanans röda linje"
    case "METRO-BLUE":
      cell.icon.image = UIImage(named: "METRO-BLUE")
      cell.titleLabel.text = "Tunnelbanans blåa linje"
    case "TRAIN":
      let train = realTimeDepartures!.trains[trainKeys[indexPath.section]]!.first!
      cell.icon.image = UIImage(named: "TRAIN-NEUTRAL")
      if train.journeyDirection == 1 {
        cell.titleLabel.text = "Pendeltåg, södergående"
      } else if train.journeyDirection == 2 {
        cell.titleLabel.text = "Pendeltåg, norrgående"
      }
    case "TRAM":
      let tram = realTimeDepartures!.trams[tramKeys[indexPath.section]]!.first!
      cell.icon.image = UIImage(named: "TRAM-RAIL")
      cell.titleLabel.text = tram.groupOfLine
    case "LOCAL-TRAM":
      let tram = realTimeDepartures!.localTrams[localTramKeys[indexPath.section]]!.first!
      cell.icon.image = UIImage(named: "TRAM-LOCAL")
      cell.titleLabel.text = tram.groupOfLine
    case "BOAT":
      let boat = realTimeDepartures!.boats[boatKeys[indexPath.section]]!.first!
      cell.icon.image = UIImage(named: "SHIP-NEUTRAL")
      cell.titleLabel.text = boat.groupOfLine
    default:
      break
    }
  }
  
  /**
   * Set row cell data
   */
  private func setRowData(cell: RealTimeTripRow, indexPath: NSIndexPath) {
    var data: RTTransportBase?
    let tabKeys = tabTypesKeys[segmentView.indexOfSelectedSegment]
    switch tabKeys {
    case "BUS":
      data = realTimeDepartures!.busses[busKeys[indexPath.section]]![indexPath.row - 1] as RTTransportBase
    case "METRO-GREEN":
      data = realTimeDepartures!.greenMetros[metroGreenKeys[indexPath.section]]![indexPath.row - 1] as RTTransportBase
    case "METRO-RED":
      data = realTimeDepartures!.redMetros[metroRedKeys[indexPath.section]]![indexPath.row - 1] as RTTransportBase
    case "METRO-BLUE":
      data = realTimeDepartures!.blueMetros[metroBlueKeys[indexPath.section]]![indexPath.row - 1] as RTTransportBase
    case "TRAIN":
      let train = realTimeDepartures!.trains[trainKeys[indexPath.section]]![indexPath.row - 1]
      cell.lineLabel.text = train.lineNumber
      let via = ((train.secondaryDestinationName != nil) ? " via \(train.secondaryDestinationName!)" : "")
      cell.infoLabel.text = "\(train.destination)" + via
      if train.displayTime == "Nu" {
        cell.departureTimeLabel.font = UIFont.boldSystemFontOfSize(17)
        cell.departureTimeLabel.textColor = StyleHelper.sharedInstance.mainGreen
      } else {
        cell.departureTimeLabel.font = UIFont.systemFontOfSize(17)
        cell.departureTimeLabel.textColor = UIColor.blackColor()
      }
      cell.departureTimeLabel.text = train.displayTime
      cell.deviationsLabel.text = train.deviations.joinWithSeparator(" ")
      if DisturbanceTextHelper.isDisturbance(cell.deviationsLabel.text) {
        cell.deviationsLabel.textColor = UIColor(red: 173/255, green: 36/255, blue: 62/255, alpha: 1.0)
      } else {
        cell.deviationsLabel.textColor = UIColor.darkGrayColor()
      }
      return
    case "TRAM":
      data = realTimeDepartures!.trams[tramKeys[indexPath.section]]![indexPath.row - 1] as RTTransportBase
    case "LOCAL-TRAM":
      data = realTimeDepartures!.localTrams[localTramKeys[indexPath.section]]![indexPath.row - 1] as RTTransportBase
    case "BOAT":
      data = realTimeDepartures!.boats[boatKeys[indexPath.section]]![indexPath.row - 1] as RTTransportBase
    default:
      break
    }
    
    if let data = data {
      cell.lineLabel.text = data.lineNumber
      cell.infoLabel.text = "\(data.destination)"
      if data.displayTime == "Nu" {
        cell.departureTimeLabel.font = UIFont.boldSystemFontOfSize(17)
        cell.departureTimeLabel.textColor = StyleHelper.sharedInstance.mainGreen
      } else {
        cell.departureTimeLabel.font = UIFont.systemFontOfSize(17)
        cell.departureTimeLabel.textColor = UIColor.blackColor()
      }
      cell.departureTimeLabel.text = data.displayTime
      cell.deviationsLabel.text = data.deviations.joinWithSeparator(" ")
      if DisturbanceTextHelper.isDisturbance(cell.deviationsLabel.text) {
        cell.deviationsLabel.textColor = UIColor(red: 173/255, green: 36/255, blue: 62/255, alpha: 1.0)
      } else {
        cell.deviationsLabel.textColor = UIColor.darkGrayColor()
      }
    }
  }
  
  deinit {
    print("RealTimeVC deinit")
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
}