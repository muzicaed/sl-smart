//
//  TripRow.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-12-07.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import WatchKit

class TripRow: NSObject {
  
  
  @IBOutlet var scheduleLabel: WKInterfaceLabel!
  @IBOutlet var travelTimeLabel: WKInterfaceLabel!
  @IBOutlet var travelDateLabel: WKInterfaceLabel!
  
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
  
  var icons = [WKInterfaceImage]()
  var iconLables = [WKInterfaceLabel]()
  var iconGroups = [WKInterfaceGroup]()

  /**
   * Set data for row
   */
  func setData(data: Dictionary<String, AnyObject>) {
    let depDateString = "Gå " + DateUtils.createDepartureTimeString(data["originTime"] as! String)
    let arrivalDate = DateUtils.convertDateString(data["destinationTime"] as! String)
    let humanTripDuration = createHumanTripDuration(data["dur"] as! Int)
    
    scheduleLabel.setText("\(depDateString) → \(DateUtils.dateAsTimeString(arrivalDate))")
    travelTimeLabel.setText("Restid: \(humanTripDuration)")
    createTripIcons(data["icn"] as! [String], lines: data["lns"] as! [String])
  }
  
  // MARK: Private
  
  /**
   * Creates trip icons
   */
  private func createTripIcons(iconNames: [String], lines: [String]) {
    prepareIcons()
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
  private func prepareIcons() {
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
}