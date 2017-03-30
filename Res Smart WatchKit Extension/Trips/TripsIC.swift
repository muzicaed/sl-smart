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
  
  let session = WCSession.default()
  var data: Dictionary<String, AnyObject>?
  var tripData = [Dictionary<String, AnyObject>]()
  var wasLoadedDate = Date()
  
  /**
   * On load
   */
  override func awake(withContext context: Any?) {
    super.awake(withContext: context)
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
    let diffMin = Int((Date().timeIntervalSince1970 - wasLoadedDate.timeIntervalSince1970) / 60)
    return diffMin > 2
  }
  
  /**
   * Handle reply for a "SearchTrips" message.
   */
  func searchTripsHandler(_ reply: Data) {
    let dictionary = NSKeyedUnarchiver.unarchiveObject(with: reply)! as! Dictionary<String, AnyObject>
    if dictionary["error"] as! Bool {
      displayError(
        "Något gick fel".localized,
        message: "Ett fel inträffade. Kontrollera att din iPhone kan nå internet.".localized)
      return
    }
    
    tripData = dictionary["trips"] as! [Dictionary<String, AnyObject>]
    if tripData.count > 0 {
      updateTripTable()
      loadingLabel.setHidden(true)
      tripTable.setHidden(false)
      if data == nil {
        originLabel.setText(tripData[0]["ori"] as? String)
        destinationLabel.setText(tripData[0]["des"] as? String)
      }
    } else {
      loadingLabel.setText("Inga resor".localized)
    }
  }
  
  // MARK: Private
  
  /**
   * Loads trip data from partner iPhone
   */
  fileprivate func loadData() {
    var id = ""
    var action = "SearchLastTrip"
    if let data = data {
      id = data["id"] as! String
      action = "SearchTrips"
    }
    
    let dictionary = ["action": action, "id": id]
    let nsData = NSKeyedArchiver.archivedData(withRootObject: dictionary)
    if session.isReachable {
      session.sendMessageData(
        nsData,
        replyHandler: searchTripsHandler,
        errorHandler: { error in
          self.displayError(
            "Något gick fel".localized,
            message: "Ett fel inträffade. Kontrollera att din iPhone kan nå internet.")
      })
    } else {
      displayError(
        "Kan inte nå din iPhone".localized,
        message: "Kontrollera att din iPhone är i närheten och påslagen.".localized)
    }
  }
  
  /**
   * Update ui
   */
  fileprivate func updateUI() {
    if let data = data {
      titleLabel.setText(data["tit"] as? String)
      originLabel.setText(data["ori"] as? String)
      destinationLabel.setText(data["des"] as? String)
    } else {
      titleLabel.setText("Senaste sökning".localized)
      originLabel.setText("")
      destinationLabel.setText("")
    }
  }
  
  /**
   * Update table based on trip data.
   */
  fileprivate func updateTripTable() {
    if tripData.count > 0 {
      tripTable.setNumberOfRows(tripData.count, withRowType: "TripRow")
      for (index, data) in tripData.enumerated() {
        let row = tripTable.rowController(at: index) as! TripRow
        row.setData(data)
      }
    }
    loadingLabel.setHidden(true)
  }
  
  /**
   * Displays an error
   */
  fileprivate func displayError(_ title: String, message: String?) {
    WKInterfaceDevice.current().play(WKHapticType.failure)
    let okAction = WKAlertAction(title: "Försök igen".localized, style: .default, handler: {
      self.popToRootController()
    })
    presentAlert(withTitle: title,
                                    message: message, preferredStyle: .alert, actions: [okAction])
  }
}
