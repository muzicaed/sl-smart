//
//  TripsIC.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-12-07.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class TripsIC: WKInterfaceController {
  
  @IBOutlet var titleLabel: WKInterfaceLabel!
  @IBOutlet var originLabel: WKInterfaceLabel!
  @IBOutlet var destinationLabel: WKInterfaceLabel!
  @IBOutlet var loadingLabel: WKInterfaceLabel!
  @IBOutlet var tripTable: WKInterfaceTable!
  
  let session = WCSession.defaultSession()
  var data: Dictionary<String, AnyObject>?
  var tripData = [Dictionary<String, AnyObject>]()
  var wasLoadedDate = NSDate()
  
  /**
   * On load
   */
  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)
    tripTable.setHidden(true)
    data = context as? Dictionary<String, AnyObject>
  }
  
  /**
   * About to show
   */
  override func willActivate() {
    super.willActivate()
    if checkOldData() {
      // Go back
      popToRootController()
      return
    }
    
    updateUI()
    loadingLabel.setHidden(false)
    if tripData.count > 1 {
      updateTripTable()
      loadingLabel.setHidden(true)
      tripTable.setHidden(false)
    } else {
      loadData()
    }
  }
  
  /**
   * Checks if on screen data is
   * outdated.
   */
  func checkOldData() -> Bool {
    let diffMin = Int((NSDate().timeIntervalSince1970 - wasLoadedDate.timeIntervalSince1970) / 60)
    return diffMin > 2
  }
  
  /**
   * Handle reply for a "SearchTrips" message.
   */
  func searchTripsHandler(reply: Dictionary<String, AnyObject>) {
    if reply["error"] as! Bool {
      displayError("Något gick fel",
        message: "Söktjänsten är inte tillgänglig.\nKontrollera att din iPhone har tillgång till internet och försök igen.")
      return
    }
    
    tripData = reply["trips"] as! [Dictionary<String, AnyObject>]
    if tripData.count > 0 {
      updateTripTable()
      loadingLabel.setHidden(true)
      tripTable.setHidden(false)
      if data == nil {
        originLabel.setText(tripData[0]["origin"] as? String)
        destinationLabel.setText(tripData[0]["destination"] as? String)
      }
    } else {
      loadingLabel.setText("Inga resor")
    }
    WKInterfaceDevice.currentDevice().playHaptic(WKHapticType.Success)    
  }
  
  // MARK: Private
  
  /**
  * Loads trip data from partner iPhone
  */
  private func loadData() {
    var id = ""
    var action = "SearchLastTrip"
    if let data = data {
      id = data["id"] as! String
      action = "SearchTrips"
    }
    if session.reachable {
      session.sendMessage(
        [
          "action": action,
          "id": id
        ],
        replyHandler: searchTripsHandler,
        errorHandler: { error in
          self.displayError("Något gick fel",
            message: "Söktjänsten är inte tillgänglig.\nKontrollera att din iPhone har tillgång till internet och försök igen.")
      })
    } else {
      displayError("Hittar inte din iPhone",
        message: "Det går inte att kommunicera med din iPhone. Kontrollera att den är laddad och finns i närheten.")
    }
  }
  
  /**
   * Update ui
   */
  private func updateUI() {
    if let data = data {
      titleLabel.setText(data["tit"] as? String)
      originLabel.setText(data["ori"] as? String)
      destinationLabel.setText(data["des"] as? String)
    } else {
      titleLabel.setText("Senaste sökning")
      originLabel.setText("")
      destinationLabel.setText("")
    }
  }
  
  /**
   * Update table based on trip data.
   */
  private func updateTripTable() {
    if tripData.count > 0 {
      tripTable.setNumberOfRows(tripData.count, withRowType: "TripRow")
      for (index, data) in tripData.enumerate() {
        let row = tripTable.rowControllerAtIndex(index) as! TripRow
        row.setData(data)
      }
    }
    loadingLabel.setHidden(true)
  }  
  
  /**
   * Displays an error
   */
  private func displayError(title: String, message: String?) {
    WKInterfaceDevice.currentDevice().playHaptic(WKHapticType.Failure)
    let okAction = WKAlertAction(title: "Försök igen", style: .Default, handler: {
      self.popToRootController()
    })
    presentAlertControllerWithTitle(title,
      message: message, preferredStyle: .Alert, actions: [okAction])
  }
}
