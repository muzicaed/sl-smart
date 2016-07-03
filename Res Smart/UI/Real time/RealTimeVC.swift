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
  var metroKeys = [String]()
  var trainKeys = [String]()
  var tramKeys = [String]()
  var localTramKeys = [String]()
  var boatKeys = [String]()
  
  var tabTypesKeys = [String]()
  var segmentView = SMSegmentView()
  var refreshTimmer: NSTimer?
  let loadedTime = NSDate()
  let refreshController = UIRefreshControl()
  var tableActivityIndicator = UIActivityIndicatorView(
    activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
  
  /**
   * On load
   */
  override func viewDidLoad() {
    topView.alpha = 0.0
    tableView.tableFooterView = UIView()
    setupTableActivityIndicator()
    
    NSNotificationCenter.defaultCenter().addObserver(
      self, selector: #selector(didBecomeActive),
      name: UIApplicationDidBecomeActiveNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(
      self, selector: #selector(didBecomeInactive),
      name: UIApplicationWillResignActiveNotification, object: nil)
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 44

    refreshController.addTarget(
      self, action: #selector(loadData), forControlEvents: UIControlEvents.ValueChanged)
    refreshController.tintColor = UIColor.lightGrayColor()
    tableView.addSubview(refreshController)
    tableView.alwaysBounceVertical = true
  }
  
  /**
   * View will appear
   */
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    tableView.reloadData()
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
    if now.timeIntervalSinceDate(loadedTime) > (60 * 60) { // 1 hour
      navigationController?.popToRootViewControllerAnimated(false)
      return
    }
    tableView.reloadData()
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
      15.0, target: self, selector: #selector(loadData), userInfo: nil, repeats: true)
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
    NetworkActivity.displayActivityIndicator(true)
    RealTimeDeparturesService.fetch(siteId) { (rtDepartures, error) -> Void in
      NetworkActivity.displayActivityIndicator(false)
      if error == nil {
        if let departures = rtDepartures {
          dispatch_async(dispatch_get_main_queue(), {
            self.spinnerView.removeFromSuperview()
            self.refreshController.endRefreshing()
            self.isLoading = false
            self.firstTimeLoad = false
            self.realTimeDepartures = departures
            self.setupKeys()
            self.prepareSegmentView()
            self.tableView.backgroundView = nil
            self.tableView.reloadData()
          })
        }
      }
    }
  }
  
  /**
   * On user drags down
   */
  func onRefreshController() {
    setupTableActivityIndicator()
    isLoading = true
    tableView.reloadData()
    NSTimer.scheduledTimerWithTimeInterval(
      0.7, target: self, selector: #selector(loadData), userInfo: nil, repeats: false)
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
    UserPreferenceStore.sharedInstance.setLastRealTimeTripType(tabTypesKeys[index])
    tableView.reloadData()
  }
  
  // MARK: Private
  
  /**
   * Prepares Segment View
   */
  private func prepareSegmentView() {
    segmentView.removeFromSuperview()
    segmentView = SMSegmentView(
      frame: CGRect(x: 0, y: 0, width: 100.0, height: 44),
      separatorColour: UIColor.lightGrayColor(),
      separatorWidth: 0.0,
      segmentProperties: [
        keySegmentOnSelectionTextColour: UIColor.blackColor(),
        keySegmentTitleFont: UIFont.systemFontOfSize(12.0),
        keySegmentOnSelectionColour: UIColor(red: 22/255, green: 173/255, blue: 126/255, alpha: 0.5),
        keySegmentOffSelectionColour: UIColor.clearColor(),
        keyContentVerticalMargin: 10.0])
    
    var tabCount = 0
    let lastStoredSelected = UserPreferenceStore.sharedInstance.getLastRealTimeTripType()
    if realTimeDepartures?.busses.count > 0 {
      lastSelected = (lastStoredSelected == "BUS") ? tabCount : lastSelected
      tabCount += 1
      tabTypesKeys.append("BUS")
      segmentView.addSegmentWithTitle(
        "Bussar",
        onSelectionImage: UIImage(named: "BUS"),
        offSelectionImage: UIImage(named: "BUS"))
    }
    
    if realTimeDepartures?.metros.count > 0 {
      lastSelected = (lastStoredSelected == "METRO") ? tabCount : lastSelected
      tabCount += 1
      tabTypesKeys.append("METRO")
      segmentView.addSegmentWithTitle(
        "T-bana",
        onSelectionImage: UIImage(named: "METRO"),
        offSelectionImage: UIImage(named: "METRO"))
    }
    if realTimeDepartures?.trains.count > 0 {
      lastSelected = (lastStoredSelected == "TRAIN") ? tabCount : lastSelected
      tabCount += 1
      tabTypesKeys.append("TRAIN")
      segmentView.addSegmentWithTitle(
        "Pendel",
        onSelectionImage: UIImage(named: "TRAIN"),
        offSelectionImage: UIImage(named: "TRAIN"))
    }
    if realTimeDepartures?.trams.count > 0 {
      lastSelected = (lastStoredSelected == "TRAM") ? tabCount : lastSelected
      tabCount += 1
      tabTypesKeys.append("TRAM")
      segmentView.addSegmentWithTitle(
        "Spår",
        onSelectionImage: UIImage(named: "TRAM"),
        offSelectionImage: UIImage(named: "TRAM"))
    }
    if realTimeDepartures?.localTrams.count > 0 {
      lastSelected = (lastStoredSelected == "LOCAL-TRAM") ? tabCount : lastSelected
      tabCount += 1
      tabTypesKeys.append("LOCAL-TRAM")
      segmentView.addSegmentWithTitle(
        "Spår",
        onSelectionImage: UIImage(named: "TRAM"),
        offSelectionImage: UIImage(named: "TRAM"))
    }
    if realTimeDepartures?.boats.count > 0 {
      lastSelected = (lastStoredSelected == "BOAT") ? tabCount : lastSelected
      tabCount += 1
      tabTypesKeys.append("BOAT")
      segmentView.addSegmentWithTitle(
        "Färja",
        onSelectionImage: UIImage(named: "SHIP"),
        offSelectionImage: UIImage(named: "SHIP"))
    }
    
    if tabCount > 0 {
      let screenWidth = UIScreen.mainScreen().bounds.width
      segmentView.delegate = self
      segmentView.selectSegmentAtIndex(lastSelected)
      segmentView.frame.size.width = CGFloat((screenWidth / 4) * CGFloat(tabCount))
      topView.addSubview(segmentView)
      topView.alpha = 1.0
    }
  }
  
  /**
   * Create header cell
   */
  private func createHeaderCell(indexPath: NSIndexPath) -> RealTimeHeaderRow {
    let cell = tableView!.dequeueReusableCellWithIdentifier(
      "Header", forIndexPath: indexPath) as! RealTimeHeaderRow
    
    setHeaderData(cell, indexPath: indexPath)
    return cell
  }
  
  /**
   * Create bus trip cell
   */
  private func createBussTripCell(indexPath: NSIndexPath) -> RealTimeTripRow {
    let cell = tableView!.dequeueReusableCellWithIdentifier(
      "TripRow", forIndexPath: indexPath) as! RealTimeTripRow
    
    setRowData(cell, indexPath: indexPath)
    return cell
  }
  
  /**
   * Create not found cell
   */
  private func createNotFoundCell(indexPath: NSIndexPath) -> UITableViewCell {
    return tableView!.dequeueReusableCellWithIdentifier(
      "NotFoundRow", forIndexPath: indexPath)
  }
  
  /**
   * Setup key arrays
   */
  private func setupKeys() {
    busKeys = realTimeDepartures!.busses.keys.sort(<)
    metroKeys = realTimeDepartures!.metros.keys.sort(<)
    trainKeys = realTimeDepartures!.trains.keys.sort(<)
    tramKeys = realTimeDepartures!.trams.keys.sort(<)
    localTramKeys = realTimeDepartures!.localTrams.keys.sort(<)
    boatKeys = realTimeDepartures!.boats.keys.sort(<)
  }
  
  /**
   * Calculates the needed sections.
   */
  private func calcSectionCount() -> Int {
    if tabTypesKeys.count == 0 {
      return 1
    }
    
    if let realTimeDepartures = realTimeDepartures {
      let tabKeys = tabTypesKeys[segmentView.indexOfSelectedSegment]
      switch tabKeys {
      case "BUS":
        return realTimeDepartures.busses.count
      case "METRO":
        return realTimeDepartures.metros.count
      case "TRAIN":
        return realTimeDepartures.trains.count
      case "TRAM":
        return realTimeDepartures.trams.count
      case "LOCAL-TRAM":
        return realTimeDepartures.localTrams.count
      case "BOAT":
        return realTimeDepartures.boats.count
      default:
        return 0
      }
    }
    return 0
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
      if realTimeDepartures!.busses.count == 1 {
        return realTimeDepartures!.busses[busKeys[section]]!.count + 1
      } else if realTimeDepartures!.busses.count == 2 {
        return min(realTimeDepartures!.busses[busKeys[section]]!.count + 1, 8)
      }
      return min(realTimeDepartures!.busses[busKeys[section]]!.count + 1, 5)
    case "METRO":
      return min(realTimeDepartures!.metros[metroKeys[section]]!.count + 1, 5)
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
      cell.titleLabel.text = bus.stopAreaName
      cell.titleLabel.accessibilityLabel = "Bussar, \(bus.stopAreaName)"
    case "METRO":
      let metro = realTimeDepartures!.metros[metroKeys[indexPath.section]]!.first!
      switch metro.metroLineId {
      case 1:
        cell.titleLabel.text = "Gröna linjen"
        cell.titleLabel.accessibilityLabel = "Tunnelbanas gröna linjen"
      case 2:
        cell.titleLabel.text = "Röda linjen"
        cell.titleLabel.accessibilityLabel = "Tunnelbanas röda linjen"
      case 3:
        cell.titleLabel.text = "Blå linjen"
        cell.titleLabel.accessibilityLabel = "Tunnelbanas blå linjen"
      default:
        break
      }
    case "TRAIN":
      let train = realTimeDepartures!.trains[trainKeys[indexPath.section]]!.first!
      if train.journeyDirection == 1 {
        cell.titleLabel.text = "Pendeltåg, södergående"
      } else if train.journeyDirection == 2 {
        cell.titleLabel.text = "Pendeltåg, norrgående"
      }
    case "TRAM":
      let tram = realTimeDepartures!.trams[tramKeys[indexPath.section]]!.first!
      cell.titleLabel.text = tram.groupOfLine
    case "LOCAL-TRAM":
      let tram = realTimeDepartures!.localTrams[localTramKeys[indexPath.section]]!.first!
      cell.titleLabel.text = tram.groupOfLine
    case "BOAT":
      let boat = realTimeDepartures!.boats[boatKeys[indexPath.section]]!.first!
      cell.titleLabel.text = boat.stopAreaName
    default:
      break
    }
  }
  
  /**
   * Set row cell data
   */
  private func setRowData(cell: RealTimeTripRow, indexPath: NSIndexPath) {
    var data: RTTransportBase?
    var lineChar = ""
    let tabKeys = tabTypesKeys[segmentView.indexOfSelectedSegment]
    cell.stopPointDesignation.hidden = true
    
    switch tabKeys {
    case "BUS":
      let bus = realTimeDepartures!.busses[busKeys[indexPath.section]]![indexPath.row - 1]
      data = bus as RTTransportBase
      if let designation = bus.stopPointDesignation {
        cell.stopPointDesignation.text = designation
        cell.stopPointDesignation.accessibilityLabel = "Hållplatsläge: " + designation
        cell.stopPointDesignation.hidden = false
      }
    case "METRO":
      lineChar = "T"
      data = realTimeDepartures!.metros[metroKeys[indexPath.section]]![indexPath.row - 1] as RTTransportBase
    case "TRAIN":
      let train = realTimeDepartures!.trains[trainKeys[indexPath.section]]![indexPath.row - 1]
      cell.lineLabel.text = "J" + train.lineNumber
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
        cell.deviationsLabel.textColor = StyleHelper.sharedInstance.warningColor
      } else {
        cell.deviationsLabel.textColor = UIColor.darkGrayColor()
      }
      return
    case "TRAM":
      lineChar = "L"
      data = realTimeDepartures!.trams[tramKeys[indexPath.section]]![indexPath.row - 1] as RTTransportBase
    case "LOCAL-TRAM":
      lineChar = "S"
      data = realTimeDepartures!.localTrams[localTramKeys[indexPath.section]]![indexPath.row - 1] as RTTransportBase
    case "BOAT":
      data = realTimeDepartures!.boats[boatKeys[indexPath.section]]![indexPath.row - 1] as RTTransportBase
    default:
      break
    }
    
    if let data = data {      
      cell.lineLabel.text = lineChar + data.lineNumber
      cell.infoLabel.text = "\(data.destination)"
      cell.infoLabel.accessibilityLabel = "Mot \(data.destination)"
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
        cell.deviationsLabel.textColor = StyleHelper.sharedInstance.warningColor
      } else {
        cell.deviationsLabel.textColor = UIColor.darkGrayColor()
      }
    }
  }
  
  /**
   * Setup table's background spinner.
   */
  private func setupTableActivityIndicator() {
    tableActivityIndicator.startAnimating()
    tableActivityIndicator.color = UIColor.lightGrayColor()
    tableView?.backgroundView = tableActivityIndicator
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
}