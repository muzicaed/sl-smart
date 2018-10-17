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
    func setData(_ data: Dictionary<String, AnyObject>) {
        let depDateString = DateUtils.createDepartureTimeString(
            data["ot"] as! String, isWalk: checkIfWalk(data))
        let arrivalDate = DateUtils.convertDateString(data["dt"] as! String)
        let humanTripDuration = createHumanTripDuration(data["dur"] as! Int)
        
        scheduleLabel.setText("\(depDateString) → \(DateUtils.dateAsTimeString(arrivalDate))")
        travelTimeLabel.setText("Trip time".localized  + ": \(humanTripDuration)")
        handleTravelDateLabel(data["ot"] as! String)
        createTripIcons(
            data["icn"] as! [String],
            lines: data["lns"] as! [String],
            warnings: data["war"] as! [String])
    }
    
    // MARK: Private
    
    /**
     * Handle travel date label
     */
    fileprivate func handleTravelDateLabel(_ dateStr: String) {
        let date = DateUtils.convertDateString(dateStr)
        if Calendar.current.isDateInToday(date) {
            travelDateLabel.setHidden(true)
        } else {
            travelDateLabel.setHidden(false)
            travelDateLabel.setText(DateUtils.friendlyDateAndTime(date))
        }
        
        if date.timeIntervalSinceNow < (60*1) * -1 {
            travelTimeLabel.setText("Already departed".localized)
            scheduleLabel.setTextColor(UIColor.lightGray)
        }
    }
    
    /**
     * Check if first segment is a walk.
     */
    fileprivate func checkIfWalk(_ data: Dictionary<String, AnyObject>) -> Bool {
        let first = (data["icn"] as! [String]).first!
        return (first == "WALK-NEUTRAL")
    }
    
    /**
     * Creates trip icons
     */
    fileprivate func createTripIcons(_ iconNames: [String], lines: [String], warnings: [String]) {
        prepareIcons()
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
    fileprivate func prepareIcons() {
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
    fileprivate func createHumanTripDuration(_ duration: Int) -> String {
        if duration < 60 {
            return "\(duration) min"
        }
        
        var remainder = String(duration % 60)
        if remainder.count <= 1 {
            remainder = "0" + remainder
        }
        return "\(duration / 60):\(remainder)h"
    }
}
