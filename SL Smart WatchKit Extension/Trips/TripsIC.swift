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
    tripData = data!["trp"] as! [Dictionary<String, AnyObject>]
  }
  
  /**
   * About to show
   */
  override func willActivate() {
    if checkOldData() {
      // Go back
      popToRootController()
      return
    }
    super.willActivate()
    updateUI()
    loadingLabel.setHidden(false)
    if tripData.count > 0 {
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
    return diffMin > 3
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
    } else {
      loadingLabel.setText("Hittade inga resor.")
    }
  }
  
  // MARK: Private
  
  /**
  * Loads trip data from partner iPhone
  */
  private func loadData() {
    if session.reachable {
      session.sendMessage(
        [
          "action": "SearchTrips",
          "oid": data!["oid"] as! Int,
          "did": data!["did"] as! Int
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
        let depDateString = DateUtils.createDepartureTimeString(data["originTime"] as! String)
        let arrivalDate = DateUtils.convertDateString(data["destinationTime"] as! String)
        let humanTripDuration = createHumanTripDuration(data["dur"] as! Int)
        
        row.scheduleLabel.setText("\(depDateString) → \(DateUtils.dateAsTimeString(arrivalDate))")
        row.travelTimeLabel.setText("Restid: \(humanTripDuration)")
        row.createTripIcons(data["icn"] as! [String], lines: data["lns"] as! [String])
        
      }
    }
    loadingLabel.setHidden(true)
  }
  
  /**
   * Creates a human readable trip duration string.
   * eg "1:32" eller "20 minuter"
   */
  private func createHumanTripDuration(duration: Int) -> String {
    if duration < 60 {
      return "\(duration) minuter"
    }
    
    var remainder = String(duration % 60)
    if remainder.characters.count <= 1 {
      remainder = "0" + remainder
    }
    return "\(duration / 60):\(remainder)h"
  }
  
  /**
   * Displays an error
   */
  private func displayError(title: String, message: String?) {
    let okAction = WKAlertAction(title: "Försök igen", style: .Default, handler: {})
    presentAlertControllerWithTitle(title,
      message: message, preferredStyle: .Alert, actions: [okAction])
  }
}
