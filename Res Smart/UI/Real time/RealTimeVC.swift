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
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


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
  var refreshTimmer: Timer?
  var loadedTime = Date()
  let refreshController = UIRefreshControl()
  var tableActivityIndicator = UIActivityIndicatorView(
    activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
  
  /**
   * On load
   */
  override func viewDidLoad() {
    topView.alpha = 0.0
    tableView.tableFooterView = UIView()
    setupTableActivityIndicator()
    
    NotificationCenter.default.addObserver(
      self, selector: #selector(didBecomeActive),
      name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    NotificationCenter.default.addObserver(
      self, selector: #selector(didBecomeInactive),
      name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 44
    
    refreshController.addTarget(
      self, action: #selector(loadData), for: UIControlEvents.valueChanged)
    refreshController.tintColor = UIColor.lightGray
    tableView.addSubview(refreshController)
    tableView.alwaysBounceVertical = true
  }
  
  /**
   * View will appear
   */
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tableView.reloadData()
    loadData()
    startRefreshTimmer()
  }
  
  /**
   * View did unload
   */
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    stopRefreshTimmer()
  }
  
  /**
   * Returned to the app.
   */
  func didBecomeActive() {
    let now = Date()
    if now.timeIntervalSince(loadedTime) > (60 * 30) { // 30 minutes
      navigationController?.popToRootViewController(animated: false)
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
    loadedTime = Date()
    stopRefreshTimmer()
    refreshTimmer = Timer.scheduledTimer(
      timeInterval: 15.0, target: self, selector: #selector(loadData), userInfo: nil, repeats: true)
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
      DispatchQueue.main.async {
        NetworkActivity.displayActivityIndicator(false)
        if error == nil {
          if let departures = rtDepartures {
            self.spinnerView.removeFromSuperview()
            self.refreshController.endRefreshing()
            self.isLoading = false
            self.firstTimeLoad = false
            self.realTimeDepartures = departures
            self.setupKeys()
            self.prepareSegmentView()
            self.tableView.backgroundView = nil
            self.tableView.reloadData()
          }
        } else {
          self.handleLoadDataError()
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
    Timer.scheduledTimer(
      timeInterval: 0.7, target: self, selector: #selector(loadData), userInfo: nil, repeats: false)
  }
  
  // MARK: UITableViewController
  
  /**
   * Section count
   */
  override func numberOfSections(in tableView: UITableView) -> Int {
    if isLoading {
      return 0
    }
    
    return calcSectionCount()
  }
  
  /**
   * Row count
   */
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if isLoading {
      return 0
    }
    
    return calcRowCount(section)
  }
  
  /**
   * Cell on index
   */
  override func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
  override func tableView(_ tableView: UITableView,
                          heightForRowAt indexPath: IndexPath) -> CGFloat {
    if isLoading {
      return tableView.bounds.height - 49 - 64 - 20 + 39
    } else if indexPath.row == 0 {
      return 34
    }
    return -1
  }
  
  // MARK: SMSegmentViewDelegate
  
  func segmentView(_ segmentView: SMBasicSegmentView, didSelectSegmentAtIndex index: Int) {
    lastSelected = index
    UserPreferenceStore.sharedInstance.setLastRealTimeTripType(tabTypesKeys[index])
    tableView.reloadData()
  }
  
  // MARK: Private
  
  /**
   * Prepares Segment View
   */
  fileprivate func prepareSegmentView() {
    segmentView.removeFromSuperview()
    segmentView = SMSegmentView(
      frame: CGRect(x: 0, y: 0, width: 100.0, height: 44),
      separatorColour: UIColor.lightGray,
      separatorWidth: 0.0,
      segmentProperties: [
        keySegmentOnSelectionTextColour: UIColor.black,
        keySegmentTitleFont: UIFont.systemFont(ofSize: 12),
        keySegmentOnSelectionColour: UIColor(red: 22/255, green: 173/255, blue: 126/255, alpha: 0.5),
        keySegmentOffSelectionColour: UIColor.clear,
        keyContentVerticalMargin: 10.0 as AnyObject])
    
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
      let screenWidth = UIScreen.main.bounds.width
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
  fileprivate func createHeaderCell(_ indexPath: IndexPath) -> RealTimeHeaderRow {
    let cell = tableView!.dequeueReusableCell(
      withIdentifier: "Header", for: indexPath) as! RealTimeHeaderRow
    
    setHeaderData(cell, indexPath: indexPath)
    return cell
  }
  
  /**
   * Create bus trip cell
   */
  fileprivate func createBussTripCell(_ indexPath: IndexPath) -> RealTimeTripRow {
    let cell = tableView!.dequeueReusableCell(
      withIdentifier: "TripRow", for: indexPath) as! RealTimeTripRow
    
    setRowData(cell, indexPath: indexPath)
    return cell
  }
  
  /**
   * Create not found cell
   */
  fileprivate func createNotFoundCell(_ indexPath: IndexPath) -> UITableViewCell {
    return tableView!.dequeueReusableCell(
      withIdentifier: "NotFoundRow", for: indexPath)
  }
  
  /**
   * Setup key arrays
   */
  fileprivate func setupKeys() {
    busKeys = realTimeDepartures!.busses.keys.sorted(by: <)
    metroKeys = realTimeDepartures!.metros.keys.sorted(by: <)
    trainKeys = realTimeDepartures!.trains.keys.sorted(by: <)
    tramKeys = realTimeDepartures!.trams.keys.sorted(by: <)
    localTramKeys = realTimeDepartures!.localTrams.keys.sorted(by: <)
    boatKeys = realTimeDepartures!.boats.keys.sorted(by: <)
  }
  
  /**
   * Calculates the needed sections.
   */
  fileprivate func calcSectionCount() -> Int {
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
  fileprivate func calcRowCount(_ section: Int) -> Int {
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
  fileprivate func setHeaderData(_ cell: RealTimeHeaderRow, indexPath: IndexPath) {
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
  fileprivate func setRowData(_ cell: RealTimeTripRow, indexPath: IndexPath) {
    var data: RTTransportBase?
    var lineChar = ""
    let tabKeys = tabTypesKeys[segmentView.indexOfSelectedSegment]
    cell.stopPointDesignation.isHidden = true
    
    switch tabKeys {
    case "BUS":
      let bus = realTimeDepartures!.busses[busKeys[indexPath.section]]![indexPath.row - 1]
      data = bus as RTTransportBase
      if let designation = bus.stopPointDesignation {
        cell.stopPointDesignation.text = designation
        cell.stopPointDesignation.accessibilityLabel = "Hållplatsläge: " + designation
        cell.stopPointDesignation.isHidden = false
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
        cell.departureTimeLabel.font = UIFont.systemFont(ofSize: 16)
        cell.departureTimeLabel.textColor = StyleHelper.sharedInstance.mainGreen
      } else {
        cell.departureTimeLabel.font = UIFont.systemFont(ofSize: 16)
        cell.departureTimeLabel.textColor = UIColor.black
      }
      cell.departureTimeLabel.text = train.displayTime
      cell.deviationsLabel.text = train.deviations.joined(separator: " ")
      if DisturbanceTextHelper.isDisturbance(cell.deviationsLabel.text) {
        cell.deviationsLabel.textColor = StyleHelper.sharedInstance.warningColor
      } else {
        cell.deviationsLabel.textColor = UIColor.darkGray
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
        cell.departureTimeLabel.font = UIFont.boldSystemFont(ofSize: 17)
        cell.departureTimeLabel.textColor = StyleHelper.sharedInstance.mainGreen
      } else {
        cell.departureTimeLabel.font = UIFont.systemFont(ofSize: 17)
        cell.departureTimeLabel.textColor = UIColor.black
      }
      cell.departureTimeLabel.text = data.displayTime
      cell.deviationsLabel.text = data.deviations.joined(separator: " ")
      if DisturbanceTextHelper.isDisturbance(cell.deviationsLabel.text) {
        cell.deviationsLabel.textColor = StyleHelper.sharedInstance.warningColor
      } else {
        cell.deviationsLabel.textColor = UIColor.darkGray
      }
    }
  }
  
  /**
   * Hadle load data (network) error
   */
  fileprivate func handleLoadDataError() {
    stopRefreshTimmer()
    let invalidLoadingAlert = UIAlertController(
      title: "Kan inte nå söktjänsten",
      message: "Söktjänsten kan inte nås just nu. Prova igen om en liten stund.",
      preferredStyle: UIAlertControllerStyle.alert)
    invalidLoadingAlert.addAction(
      UIAlertAction(title: "Okej", style: UIAlertActionStyle.default, handler: { _ in
        self.navigationController?.popToRootViewController(animated: false)
      }))
    
    present(invalidLoadingAlert, animated: true, completion: nil)
  }
  
  /**
   * Setup table's background spinner.
   */
  fileprivate func setupTableActivityIndicator() {
    tableActivityIndicator.startAnimating()
    tableActivityIndicator.color = UIColor.lightGray
    tableView?.backgroundView = tableActivityIndicator
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
}
