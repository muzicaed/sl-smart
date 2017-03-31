//
//  SmartTripIC.swift
//  SL Smart WatchKit Extension
//
//  Created by Mikael Hellman on 2015-11-20.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class SmartTripIC: WKInterfaceController {
  
  @IBOutlet var containerGroup: WKInterfaceGroup!
  @IBOutlet var titleLabel: WKInterfaceLabel!
  @IBOutlet var departureTimeLabel: WKInterfaceLabel!
  @IBOutlet var originLabel: WKInterfaceLabel!
  @IBOutlet var destinationLabel: WKInterfaceLabel!
  @IBOutlet var loadingLabel: WKInterfaceLabel!
  @IBOutlet var otherRoutinesTable: WKInterfaceTable!
  @IBOutlet var otherRoutinesLabel: WKInterfaceLabel!
  
  @IBOutlet var icon1: WKInterfaceImage!
  @IBOutlet var icon2: WKInterfaceImage!
  @IBOutlet var icon3: WKInterfaceImage!
  @IBOutlet var icon4: WKInterfaceImage!
  @IBOutlet var icon5: WKInterfaceImage!
  @IBOutlet var icnLbl1: WKInterfaceLabel!
  @IBOutlet var icnLbl2: WKInterfaceLabel!
  @IBOutlet var icnLbl3: WKInterfaceLabel!
  @IBOutlet var icnLbl4: WKInterfaceLabel!
  @IBOutlet var icnLbl5: WKInterfaceLabel!
  @IBOutlet var icnGrp1: WKInterfaceGroup!
  @IBOutlet var icnGrp2: WKInterfaceGroup!
  @IBOutlet var icnGrp3: WKInterfaceGroup!
  @IBOutlet var icnGrp4: WKInterfaceGroup!
  @IBOutlet var icnGrp5: WKInterfaceGroup!
  
  let session = WCSession.default()
  let notificationCenter = NotificationCenter.default
  let ReloadRateMinutes = 3
  
  var icons = [WKInterfaceImage]()
  var iconLables = [WKInterfaceLabel]()
  var iconGroups = [WKInterfaceGroup]()
  var lastUpdated = Date(timeIntervalSince1970: TimeInterval(0.0))
  var routineData: Dictionary<String, AnyObject>?
  var isLoading = false
  var timer: Timer?
  var retryTimer: Timer?
  var retryCount = 0
  var currentDepartureText: String?
  
  override func awake(withContext context: Any?) {
    super.awake(withContext: context)
    prepareIcons()
  }
  
  /**
   * About to show on screen.
   */
  override func willActivate() {
    super.willActivate()
    refreshData()
  }
  
  /**
   * Interface disappear.
   */
  override func willDisappear() {
    super.willDisappear()
    hideLiveData()
  }
  
  /**
   * Interface deactivated.
   */
  override func didDeactivate() {
    super.didDeactivate()
    stopRefreshTimer()
    isLoading = false
  }
  
  /**
   * Trigger a data refresh.
   */
  func refreshData() {
    perfromRefreshData(false)
  }
  
  /**
   * Force a data refresh.
   */
  func forceRefreshData() {
    perfromRefreshData(true)
  }
  
  /**
   * Ask partner iPhone for new Routine Trip data
   */
  func reloadRoutineTripData() {
    if !isLoading {
      if session.isReachable {
        isLoading = true
        stopRefreshTimer()
        
        let dictionary = ["action": "RequestRoutineTrips"]
        let data = NSKeyedArchiver.archivedData(withRootObject: dictionary)
        session.sendMessageData(
          data,
          replyHandler: requestRoutineTripsHandler,
          errorHandler: messageErrorHandler)
        retryTimer = Timer.scheduledTimer(
          timeInterval: TimeInterval(10), target: self, selector: #selector(forceRefreshData), userInfo: nil, repeats: false)
      } else {
        retryCount += 1
        if retryCount > 10 {
          retryCount = 0
          stopRefreshTimer()
          displayError(
            "Can not reach your iPhone".localized,
            message: "Check that your iPhone is nearby and turned on.".localized)
          return
        }
        stopRefreshTimer()
        retryTimer = Timer.scheduledTimer(
          timeInterval: TimeInterval(1), target: self,
          selector: #selector(forceRefreshData),
          userInfo: nil, repeats: false)
      }
    }
  }
  
  /**
   * Handle reply for a "RequestRoutineTrips" message.
   */
  func requestRoutineTripsHandler(_ reply: Data) {
    let dictionary = NSKeyedUnarchiver.unarchiveObject(with: reply)! as! Dictionary<String, AnyObject>
    retryCount = 0
    stopRefreshTimer()
    isLoading = false
    let hasData = dictionary["?"] as! Bool
    // TODO: Validate reply?, sometime get back freaky data like "Unable to read data" (Not as an error)
    if hasData {
      routineData = dictionary
      if !handleEmptyTripResponse() {
        showContentUIState()
        lastUpdated = Date()
        startRefreshTimer()
      }
    } else {
      displayError(
        "Could not find any Smart Routines".localized,
        message: "You can manage your routines on your iPhone.".localized)
    }
  }
  
  /**
   * Handles any session send messages errors.
   */
  func messageErrorHandler(error: Error) {
    let error = error as! WCError
    isLoading = false
    WKInterfaceDevice.current().play(WKHapticType.failure)
    
    if error.code == WCError.deliveryFailed ||
      error.code == WCError.messageReplyTimedOut ||
      error.code == WCError.genericError {
      stopRefreshTimer()
      retryTimer = Timer.scheduledTimer(
        timeInterval: TimeInterval(0.1), target: self, selector: #selector(forceRefreshData),
        userInfo: nil, repeats: false)
      return
    } else if error.code == WCError.notReachable {
      displayError(
        "Kan inte nå din iPhone".localized,
        message: "Kontrollera att din iPhone är i närheten och påslagen.".localized)
      return
    }
    
     displayError(
     "Something went wrong".localized,
     message: "An error occurred. Check your internet connection.".localized)
  }
  
  /**
   * Checks if no trips was found for best routine,
   * and updates UI in this case.
   * Returns true if no trips was found.
   */
  func handleEmptyTripResponse() -> Bool {
    if let data = routineData {
      let bestRoutine = data["b"] as! Dictionary<String, AnyObject>
      let trips = bestRoutine["tr"] as! [Dictionary<String, AnyObject>]
      
      if trips.count == 0 {
        WKInterfaceDevice.current().play(WKHapticType.failure)
        updateUINoTripsFound(bestRoutine)
        return true
      }
    }
    
    return false
  }
  
  /**
   * Updates UI if no trips was found
   * for best routine.
   */
  func updateUINoTripsFound(_ bestRoutine: Dictionary<String, AnyObject>) {
    if bestRoutine["ha"] as! Bool {
      titleLabel.setText("Smart habit".localized)
    } else {
      titleLabel.setText(bestRoutine["ti"] as? String)
    }
    departureTimeLabel.setText("No trip".localized)
    originLabel.setText("")
    destinationLabel.setText("")
    containerGroup.setHidden(false)
    loadingLabel.setHidden(true)
    for (index, _) in icons.enumerated() {
      iconGroups[index].setHidden(true)
    }
  }
  
  /**
   * Updates UI using data from iPhone
   */
  func updateUIData() {
    if let data = routineData {
      let bestRoutine = data["b"] as! Dictionary<String, AnyObject>
      let icons = (bestRoutine["tr"] as! [Dictionary<String, AnyObject>]).first!["icn"] as! [String]
      let lines = (bestRoutine["tr"] as! [Dictionary<String, AnyObject>]).first!["lns"] as! [String]
      let warnings = (bestRoutine["tr"] as! [Dictionary<String, AnyObject>]).first!["war"] as! [String]
      
      updateDepatureUI()
      if bestRoutine["ha"] as! Bool {
        titleLabel.setText("Smart habit".localized)
      } else {
        titleLabel.setText(bestRoutine["ti"] as? String)
      }
      
      originLabel.setText(bestRoutine["or"] as? String)
      destinationLabel.setText(bestRoutine["ds"] as? String)
      
      createTripIcons(icons, lines: lines, warnings: warnings)
      updateOtherTable(data["o"] as! [Dictionary<String, AnyObject>])
    }
  }
  
  /**
   * Updates UI for departure time.
   */
  func updateDepatureUI() {
    if let data = routineData {
      let bestRoutine = data["b"] as! Dictionary<String, AnyObject>
      currentDepartureText = DateUtils.createDepartureTimeString(
        bestRoutine["dp"] as! String, isWalk: checkIfWalk(bestRoutine))
      departureTimeLabel.setText(currentDepartureText)
      return
    }
    // Retry after 1.5 seconds...
    retryTimer = Timer.scheduledTimer(
      timeInterval: TimeInterval(1.5), target: self, selector: #selector(forceRefreshData),
      userInfo: nil, repeats: false)
  }
  
  /**
   *  Triggred when session becomes reachable after beeing
   *  unreachable.
   */
  func onSessionBecameReachable() {
    if !isLoading {
      refreshData()
    }
  }
  
  /**
   * Creates trip icons
   */
  func createTripIcons(_ iconNames: [String], lines: [String], warnings: [String]) {
    let nameCount = iconNames.count
    for (index, iconImage) in icons.enumerated() {
      if index < nameCount {
        iconImage.setImageNamed("W_\(iconNames[index])")
        iconImage.setHidden(false)
        iconLables[index].setHidden(false)
        iconLables[index].setText(lines[index])
        if warnings[index] == "I" {
          iconLables[index].setTextColor(UIColor(red: 100/255, green: 100/255, blue: 255/255, alpha: 1.0))
        } else if warnings[index] == "W" {
          iconLables[index].setTextColor(UIColor.red)
        } else {
          iconLables[index].setTextColor(UIColor.white)
        }
        iconGroups[index].setHidden(false)
      } else {
        iconImage.setHidden(true)
        iconLables[index].setHidden(true)
        iconLables[index].setText(nil)
        iconGroups[index].setHidden(true)
      }
    }
  }
  
  /**
   * Stores all trip icons in a array
   * for easier manipulation.
   */
  func prepareIcons() {
    icons = [WKInterfaceImage]()
    icons.append(icon1)
    icons.append(icon2)
    icons.append(icon3)
    icons.append(icon4)
    icons.append(icon5)
    iconLables = [WKInterfaceLabel]()
    iconLables.append(icnLbl1)
    iconLables.append(icnLbl2)
    iconLables.append(icnLbl3)
    iconLables.append(icnLbl4)
    iconLables.append(icnLbl5)
    iconGroups = [WKInterfaceGroup]()
    iconGroups.append(icnGrp1)
    iconGroups.append(icnGrp2)
    iconGroups.append(icnGrp3)
    iconGroups.append(icnGrp4)
    iconGroups.append(icnGrp5)
  }
  
  /**
   * Displays an error
   */
  func displayError(_ title: String, message: String?) {
    isLoading = false
    let okAction = WKAlertAction(
      title: "Try again".localized, style: .default, handler: {})
    presentAlert(
      withTitle: title, message: message, preferredStyle: .alert, actions: [okAction])
  }
  
  /**
   * Updates UI to show "Loading..."
   */
  func setLoadingUIState() {
    containerGroup.setHidden(true)
    loadingLabel.setHidden(false)
  }
  
  /**
   * Updates UI to show content
   */
  func showContentUIState() {
    if !isLoading {
      updateUIData()
      containerGroup.setHidden(false)
      loadingLabel.setHidden(true)
    }
  }
  
  /**
   * Checks if the best trip have departed allreay.
   */
  func checkIfTripPassed() -> Bool {
    if let data = routineData {
      let bestRoutine = data["b"] as! Dictionary<String, AnyObject>
      let depTime = bestRoutine["dp"] as! String
      let departureDate = DateUtils.convertDateString(depTime)
      let diffMin = Int((departureDate.timeIntervalSince1970 - Date().timeIntervalSince1970) / 60)
      if diffMin < 0 {
        return true
      }
    }
    
    return false
  }
  
  /**
   * Check if first segment is a walk.
   */
  func checkIfWalk(_ data: Dictionary<String, AnyObject>) -> Bool {
    let icons = (data["tr"] as! [Dictionary<String, AnyObject>]).first!["icn"] as! [String]
    return (icons.first! == "WALK-NEUTRAL")
  }
  
  /**
   * On menu reload tap.
   */
  @IBAction func onReloadTap() {
    forceRefreshData()
  }
  
  override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
    if let data = routineData {
      let routines = data["o"] as! [Dictionary<String, AnyObject>]
      pushController(withName: "Trips", context: routines[rowIndex])
    }
  }
  
  /**
   * Handle segue
   */
  override func contextForSegue(withIdentifier segueIdentifier: String) -> Any? {
    if segueIdentifier == "ShowTrips" {
      if let data = routineData {
        return data["b"] as! Dictionary<String, AnyObject>
      }
    } else if segueIdentifier == "ShowLastSearch" {
      return nil
    }
    return nil
  }
  
  // MARK: Private
  
  /**
   * Updates the other routine trips table.
   */
  fileprivate func updateOtherTable(_ otherTripsData: [Dictionary<String, AnyObject>]) {
    if otherTripsData.count > 0 {
      otherRoutinesTable.setNumberOfRows(otherTripsData.count, withRowType: "RoutineRow")
      for (index, data) in otherTripsData.enumerated() {
        let row = otherRoutinesTable.rowController(at: index) as! OtherRoutinesRow
        row.titleLabel.setText(data["ti"] as? String)
        row.originLabel.setText(data["or"] as? String)
        row.destinationLabel.setText(data["ds"] as? String)
      }
      otherRoutinesLabel.setHidden(false)
    } else {
      otherRoutinesLabel.setHidden(true)
    }
  }
  
  /**
   * Trigger a UI refresh of routine trip data
   */
  fileprivate func perfromRefreshData(_ force: Bool) {
    if (shouldReloadData() && !isLoading) || force {
      setLoadingUIState()
      reloadRoutineTripData()
    } else {
      updateDepatureUI()
    }
  }
  
  /**
   * Checks if data should be reloaded.
   */
  fileprivate func shouldReloadData() -> Bool {
    return (
      Date().timeIntervalSince(lastUpdated) > Double(60 * ReloadRateMinutes) ||
        routineData == nil ||
        checkIfTripPassed()
    )
  }
  
  /**
   * Hides live data when user leaves glance or lock screen.
   * We do this to not have the view displaying old data
   * for a second, when UI is reloaded when the glance
   * is reactivaed.
   */
  func hideLiveData() {
    isLoading = false
    if let text = currentDepartureText {
      if text.range(of: "In".localized) != nil {
        departureTimeLabel.setText("Updating".localized)
      }
    }
  }
  
  /**
   * Start the refresh timer.
   */
  fileprivate func startRefreshTimer() {
    timer = Timer.scheduledTimer(
      timeInterval: 10, target: self,
      selector: #selector(updateDepatureUI),
      userInfo: nil, repeats: true)
  }
  
  /**
   * Stop the refresh timer.
   */
  fileprivate func stopRefreshTimer() {
    timer?.invalidate()
    timer = nil
    retryTimer?.invalidate()
    retryTimer = nil
  }
}
