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
  
  let session = WCSession.defaultSession()
  let notificationCenter = NSNotificationCenter.defaultCenter()
  var icons = [WKInterfaceImage]()
  var iconLables = [WKInterfaceLabel]()
  var iconGroups = [WKInterfaceGroup]()
  var lastUpdated = NSDate(timeIntervalSince1970: NSTimeInterval(0.0))
  var routineData: Dictionary<String, AnyObject>?
  var isLoading = false
  
  override init() {
    super.init()
    notificationCenter.addObserver(self,
      selector: Selector("onSessionBecameReachable"),
      name: "SessionBecameReachable", object: nil)
  }
  
  /**
   * About to show on screen.
   */
  override func willActivate() {
    print("SmartTripIC willActivate")
    super.willActivate()
    
    // Initial load
    if routineData == nil {
      setLoadingUIState()
      refreshData()
    } else {
      showContentUIState()
    }
  }
  
  /**
   * Trigger a data refresh.
   */
  func refreshData() {
    print("SmartTripIC refreshData")
    perfromRefreshData(false)
  }
  
  /**
   * Force a data refresh.
   */
  func forceRefreshData() {
    print("SmartTripIC forceRefreshData")
    perfromRefreshData(true)
  }
  
  /**
   * Ask partner iPhone for new Routine Trip data
   */
  func reloadRoutineTripData() {
    print("SmartTripIC reloadRoutineTripData")
    if session.reachable {
      print(" - Found valid session")
      isLoading = true
      session.sendMessage(["action": "RequestRoutineTrips"],
        replyHandler: requestRoutineTripsHandler,
        errorHandler: messageErrorHandler)
    }
  }
  
  /**
   * Handle reply for a "RequestRoutineTrips" message.
   */
  func requestRoutineTripsHandler(reply: Dictionary<String, AnyObject>) {
    print("SmartTripIC requestRoutineTripsHandler (reply handler)")
    isLoading = false
    let hasData = reply["foundData"] as! Bool
    if hasData {
      routineData = reply
      showContentUIState()
    } else {
      displayError(
        "Hittade inga Smarta Resor",
        message: "Du hanterar dina rutinresor från din iPhone.\nOm du redan gjort detta, kontrollera din iPhones internetanslutning.")
    }
  }
  
  /**
   * Handles any session send messages errors.
   */
  func messageErrorHandler(error: NSError) {
    // TODO: How to handle this error??
    isLoading = false
    print("Error Code: \(error.code)\n\(error.localizedDescription)")
    displayError("\(error.localizedDescription) (\(error.code))",
      message: "\(error.localizedDescription)")
  }
  
  /**
   * Updates UI using data from iPhone
   */
  func updateUIData() {
    print("SmartTripIC updateUIData")
    if let data = routineData {
      let bestRoutine = data["best"] as! Dictionary<String, AnyObject>
      let icons = (bestRoutine["trp"] as! [Dictionary<String, AnyObject>]).first!["icn"] as! [String]
      let lines = (bestRoutine["trp"] as! [Dictionary<String, AnyObject>]).first!["lns"] as! [String]
      
      titleLabel.setText(bestRoutine["tit"] as? String)
      originLabel.setText(bestRoutine["ori"] as? String)
      destinationLabel.setText(bestRoutine["des"] as? String)
      departureTimeLabel.setText(DateUtils.createDepartureTimeString(bestRoutine["dep"] as! String))
      createTripIcons(icons, lines: lines)
      updateOtherTable(data["other"] as! [Dictionary<String, AnyObject>])
    }
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
  func createTripIcons(iconNames: [String], lines: [String]) {
    let nameCount = iconNames.count
    for (index, iconImage) in icons.enumerate() {
      if index < nameCount {
        iconImage.setImageNamed("W_\(iconNames[index])")
        iconImage.setHidden(false)
        iconLables[index].setHidden(false)
        iconLables[index].setText(lines[index])
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
  func displayError(title: String, message: String?) {
    let okAction = WKAlertAction(title: "Försök igen", style: .Default, handler: {})
    presentAlertControllerWithTitle(title,
      message: message, preferredStyle: .Alert, actions: [okAction])
  }
  
  /**
   * Updates UI to show "Loading..."
   */
  func setLoadingUIState() {
    print("SmartTripIC setLoadingUIState")
    containerGroup.setHidden(true)
    loadingLabel.setHidden(false)
  }
  
  /**
   * Updates UI to show content
   */
  func showContentUIState() {
    print("SmartTripIC showContentUIState")
    updateUIData()
    containerGroup.setHidden(false)
    loadingLabel.setHidden(true)
  }
  
  /**
   * Checks if the best trip have departed allreay.
   */
  func checkIfTripPassed() -> Bool {
    if let data = routineData {
      let bestRoutine = data["best"] as! Dictionary<String, AnyObject>
      let depTime = bestRoutine["dep"] as! String
      let departureDate = DateUtils.convertDateString(depTime)
      let diffMin = Int((departureDate.timeIntervalSince1970 - NSDate().timeIntervalSince1970) / 60)
      if diffMin < 0 {
        return true
      }
    }
    
    return false
  }
  
  /**
   * On menu reload tap.
   */
  @IBAction func onReloadTap() {
    forceRefreshData()
  }
  
  override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
    if let data = routineData {
      let routines = data["other"] as! [Dictionary<String, AnyObject>]
      pushControllerWithName("Trips", context: routines[rowIndex])
    }
  }
  
  /**
   * Handle segue
   */
  override func contextForSegueWithIdentifier(segueIdentifier: String) -> AnyObject? {
    if segueIdentifier == "ShowTrips" {
      if let data = routineData {
        return data["best"] as! Dictionary<String, AnyObject>
      }
    }
    return nil
  }
  
  // MARK: Private
  
  /**
  * Updates the other routine trips table.
  */
  private func updateOtherTable(otherTripsData: [Dictionary<String, AnyObject>]) {
    if otherTripsData.count > 0 {
      otherRoutinesTable.setNumberOfRows(otherTripsData.count, withRowType: "RoutineRow")
      for (index, data) in otherTripsData.enumerate() {
        let row = otherRoutinesTable.rowControllerAtIndex(index) as! OtherRoutinesRow
        row.titleLabel.setText(data["tit"] as? String)
        row.originLabel.setText(data["ori"] as? String)
        row.destinationLabel.setText(data["des"] as? String)
      }
      otherRoutinesLabel.setHidden(false)
    } else {
      otherRoutinesLabel.setHidden(true)
    }
  }
  
  /**
   * Trigger a UI refresh of routine trip data
   */
  private func perfromRefreshData(force: Bool) {
    print("SmartTripIC perfromRefreshData")
    if shouldReloadData() || force {
        setLoadingUIState()
        prepareIcons()
        self.reloadRoutineTripData()
    } else {
      showContentUIState()
    }
  }
  
  /**
   * Checks if data should be reloaded.
   */
  private func shouldReloadData() -> Bool {
    return (
      lastUpdated.timeIntervalSinceNow > (60 * 5) ||
      routineData == nil ||
      checkIfTripPassed()
    )
  }
}
