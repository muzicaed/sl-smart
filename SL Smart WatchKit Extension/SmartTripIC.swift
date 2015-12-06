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


class SmartTripIC: WKInterfaceController, WCSessionDelegate {
  
  @IBOutlet var containerGroup: WKInterfaceGroup!
  @IBOutlet var titleLabel: WKInterfaceLabel!
  @IBOutlet var departureTimeLabel: WKInterfaceLabel!
  @IBOutlet var originLabel: WKInterfaceLabel!
  @IBOutlet var destinationLabel: WKInterfaceLabel!
  @IBOutlet var loadingLabel: WKInterfaceLabel!
  
  @IBOutlet var icon1: WKInterfaceImage!
  @IBOutlet var icon2: WKInterfaceImage!
  @IBOutlet var icon3: WKInterfaceImage!
  @IBOutlet var icon4: WKInterfaceImage!
  @IBOutlet var icon5: WKInterfaceImage!
  @IBOutlet var icon6: WKInterfaceImage!
  
  var session : WCSession?
  var icons = [WKInterfaceImage]()
  
  /**
   * About to show on screen.
   */
  override func willActivate() {
    super.willActivate()
    print("willActivate")
    setupPhoneConnection()
    prepareIcons()
    reloadRoutineTripData()
  }
  
  /**
   * Handle reply for a "requestRoutineTrips" message.
   */
  func requestRoutineTripsHandler(reply: [String: AnyObject]) {
    let hasData = reply["foundData"] as! Bool
    if hasData {
      let routineTripData = reply["best"] as! Dictionary<String, AnyObject>
      print("Got reply")
      print("\(routineTripData)")
      titleLabel.setText(routineTripData["tit"] as? String)
      originLabel.setText(routineTripData["ori"] as? String)
      destinationLabel.setText(routineTripData["des"] as? String)
      departureTimeLabel.setText(routineTripData["dep"] as? String)
      
      createTripIcons(routineTripData["icn"] as! [String])
      
      self.animateWithDuration(0.4, animations: {
        self.loadingLabel.setHidden(true)
        self.containerGroup.setHidden(false)
      })
    } else {
      displayErrorAlert(
        "Hittade inga Smarta Resor",
        message: "Du hanterar dina rutinresor från din iPhone.\nOm du redan gjort detta, kontrollera din iPhones internetanslutning.")
    }
  }
  
  /**
   * Handles any session send messages errors.
   */
  func messageErrorHandler(error: NSError) {
    // TODO: Debug only. Replace with generic error message before publish.
    displayErrorAlert("Fel", message: error.localizedDescription)
  }
  
  // MARK private
  
  /**
  * Ask partner iPhone for new Routine Trip data
  */
  private func reloadRoutineTripData() {
    if ((session?.reachable) != nil) {
      containerGroup.setHidden(true)
      loadingLabel.setHidden(false)
      if let sess = session {
        sess.sendMessage(["action": "requestRoutineTrips"],
          replyHandler: requestRoutineTripsHandler,
          errorHandler: messageErrorHandler)
      }
    } else {
      displayErrorAlert("Kan inte hitta din iPhone",
        message: "Det går inte att kommunicera med din iPhone. Kontrollera att den är laddad och finns i närheten.")
    }
  }
  
  /**
   * Sets up a WKSession with the partner iPhone
   */
  private func setupPhoneConnection() {
    if (WCSession.isSupported()) {
      session = WCSession.defaultSession()
      if let defaultSession = session {
        defaultSession.delegate = self;
        defaultSession.activateSession()
      } else {
        displayErrorAlert("Kan inte hitta din iPhone",
          message: "Det går inte att kommunicera med din iPhone. Kontrollera att den är laddad och finns i närheten.")
      }
    }
  }
  
  /**
   * Creates trip icons
   */
  private func createTripIcons(iconNames: [String]) {
    let nameCount = iconNames.count
    for (index, iconImage) in icons.enumerate() {
      if index < nameCount {
        print("W_\(iconNames[index])")
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
  private func prepareIcons() {
    icons = [WKInterfaceImage]()
    icons.append(icon1)
    icons.append(icon2)
    icons.append(icon3)
    icons.append(icon4)
    icons.append(icon5)
    icons.append(icon6)
  }
  
  /**
   * Displays an error alert
   */
  private func displayErrorAlert(title: String, message: String) {
    let okAction = WKAlertAction(title: "Försök igen", style: .Default, handler: {})
    presentAlertControllerWithTitle(title,
      message: message, preferredStyle: .Alert, actions: [okAction])
  }
}
