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
  
  var data: Dictionary<String, AnyObject>?
  var tripData = [Dictionary<String, AnyObject>]()
  
  /**
   * On load
   */
  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)
    data = context as? Dictionary<String, AnyObject>
    tripData = data!["trp"] as! [Dictionary<String, AnyObject>]
  }
  
  /**
   * About to show
   */
  override func willActivate() {
    super.willActivate()
    updateUI()
    loadingLabel.setHidden(false)
    if tripData.count > 0 {
      updateTripTable()
      loadingLabel.setHidden(true)
    } else {
      // Load trips from iPhone
    }
  }
  
  
  // MARK: Private
  
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
        let depDateString = createDepartureTimeString(data["originTime"] as! String)
        row.scheduleLabel.setText("\(depDateString) → \(data["destinationTime"] as! String)")
        row.travelTimeLabel.setText("Restid: \(data["dur"] as! Int) min")
        row.createTripIcons(data["icn"] as! [String], lines: data["lns"] as! [String])

      }
    }
    loadingLabel.setHidden(true)
  }
  
  /**
   * Creates a human friendly deparure time.
   */
  private func createDepartureTimeString(departureTime: String) -> String {
    var departureString = departureTime
    let now = NSDate()
    let departureDate = DateUtils.convertDateString("\(DateUtils.dateAsDateString(now)) \(departureTime)")
    let diffMin = Int((departureDate.timeIntervalSince1970 - NSDate().timeIntervalSince1970) / 60)
    if diffMin < 16 {
      departureString = (diffMin + 1 <= 1) ? "Avgår nu" : "Om \(diffMin + 1) min"
    }
    
    return departureString
  }
}
