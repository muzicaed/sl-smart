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
  @IBOutlet var icon6: WKInterfaceImage!
  
  let session = WCSession.defaultSession()
  let notificationCenter = NSNotificationCenter.defaultCenter()
  var icons = [WKInterfaceImage]()
  var lastUpdated = NSDate(timeIntervalSince1970: NSTimeInterval(0.0))
  var routineData: Dictionary<String, AnyObject>?
  var validSession = false
  
  override init() {
    super.init()
    print("SmartTripIC init()")
    notificationCenter.addObserver(self,
      selector: Selector("refreshData"),
      name: "SessionBecameReachable", object: nil)
  }
  
  /**
   * About to show on screen.
   */
  override func willActivate() {
    print("SmartTripIC willActivate")
    super.willActivate()
    validSession = session.reachable
    self.refreshData()
  }
  
  /**
   * Trigger a UI refresh of routine trip data
   */
  func refreshData() {
    print("SmartTripIC refreshData")
    if lastUpdated.timeIntervalSinceNow > (60 * 3) || routineData == nil {
      setLoadingUIState()
      prepareIcons()
      if validSession {
        self.reloadRoutineTripData()
      }
    } else {
      showContentUIState()
    }
  }
  
  /**
   * Ask partner iPhone for new Routine Trip data
   */
  func reloadRoutineTripData() {
    print("SmartTripIC reloadRoutineTripData")
    if validSession {
      session.sendMessage(["action": "requestRoutineTrips"],
        replyHandler: requestRoutineTripsHandler,
        errorHandler: messageErrorHandler)
    } else {
      displayError("Kan inte hitta din iPhone",
        message: "Det går inte att kommunicera med din iPhone. Kontrollera att den är laddad och finns i närheten.")
    }
  }
  
  /**
   * Handle reply for a "requestRoutineTrips" message.
   */
  func requestRoutineTripsHandler(reply: [String: AnyObject]) {
    print("SmartTripIC requestRoutineTripsHandler")
    print("\(reply)")
    let hasData = reply["foundData"] as! Bool
    if hasData {
      routineData = reply
      print("---------------------------------------")
      updateUIData()
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
    print("SmartTripIC messageErrorHandler")
    // TODO: Debug only. Replace with generic error message before publish.
    print("Error Code: \(error.code)\n\(error.localizedDescription)")
    displayError("Fel", message: error.localizedDescription)
  }
  
  /**
   * Updates UI using data from iPhone
   */
  func updateUIData() {
    print("SmartTripIC updateUIData")
    if let data = routineData {
      let bestRoutine = data["best"] as! Dictionary<String, AnyObject>
      titleLabel.setText(bestRoutine["tit"] as? String)
      originLabel.setText(bestRoutine["ori"] as? String)
      destinationLabel.setText(bestRoutine["des"] as? String)
      departureTimeLabel.setText(createDepartureTimeString(bestRoutine["dep"] as! String))
      createTripIcons(bestRoutine["icn"] as! [String])
      updateOtherTable(data["other"] as! [Dictionary<String, AnyObject>])
    }
  }
  
  /**
   * Creates trip icons
   */
  func createTripIcons(iconNames: [String]) {
    print("SmartTripIC createTripIcons")
    let nameCount = iconNames.count
    for (index, iconImage) in icons.enumerate() {
      if index < nameCount {
        iconImage.setImageNamed("W_\(iconNames[index])")
        iconImage.setHidden(false)
      } else {
        iconImage.setHidden(true)
      }
    }
  }
  
  /**
   * Stores all trip icons in a array
   * for easier manipulation.
   */
  func prepareIcons() {
    print("SmartTripIC prepareIcons")
    icons = [WKInterfaceImage]()
    icons.append(icon1)
    icons.append(icon2)
    icons.append(icon3)
    icons.append(icon4)
    icons.append(icon5)
    icons.append(icon6)
  }
  
  /**
   * Displays an error
   */
  func displayError(title: String, message: String?) {
    print("SmartTripIC displayError")
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
   * Creates a human friendly deparure time.
   */
  func createDepartureTimeString(departureTime: String) -> String {
    var departureString = departureTime
    let now = NSDate()
    let departureDate = DateUtils.convertDateString("\(DateUtils.dateAsDateString(now)) \(departureTime)")
    let diffMin = Int((departureDate.timeIntervalSince1970 - NSDate().timeIntervalSince1970) / 60)
    if diffMin < 16 {
      departureString = (diffMin + 1 <= 1) ? "Avgår nu" : "Om \(diffMin + 1) min"
    }
    
    return departureString
  }
  
  /**
   * On menu reload tap.
   */
  @IBAction func onReloadTap() {
    print("SmartTripIC onReloadTap")
    setLoadingUIState()
    prepareIcons()
    if validSession {
      self.reloadRoutineTripData()
    }
  }
  
  override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
    print("Tap on table row \(rowIndex)")
    if let data = routineData {
      let routines = data["other"] as! [Dictionary<String, AnyObject>]
      pushControllerWithName("Trips", context: routines[rowIndex])
    }
    
  }
  
  /**
   * Handle segue
   */
  override func contextForSegueWithIdentifier(segueIdentifier: String) -> AnyObject? {
    print(segueIdentifier)
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
}
