//
//  GlanceController.swift
//  SL Smart WatchKit Extension
//
//  Created by Mikael Hellman on 2015-11-20.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class GlanceController: SmartTripIC {
  
  @IBOutlet var subTitleLabel: WKInterfaceLabel!
  @IBOutlet var contentGroup: WKInterfaceGroup!
  @IBOutlet var departureLabel: WKInterfaceLabel!
  
  var timer: NSTimer?
  
  /**
   * Interface about to be active.
   */
  override func willActivate() {
    super.willActivate()
    timer = NSTimer.scheduledTimerWithTimeInterval(
      60 * 10, target: self,
      selector: Selector("forceRefreshData"),
      userInfo: nil, repeats: true)
  }
  
  /**
   * Interface appeard
   */
  override func didAppear() {
    super.didAppear()
    if checkIfTripPassed() {
      forceRefreshData()
    } else {
      refreshData()
      updateUIData()
    }
  }
  
  /**
   * Interface deactivated.
   */
  override func didDeactivate() {
    super.didDeactivate()
    timer?.invalidate()
    timer = nil
  }
  
  /**
   * Updates UI using data from iPhone
   */
  override func updateUIData() {
    if let data = routineData {
      let bestRoutine = data["best"] as! Dictionary<String, AnyObject>
      let icons = (bestRoutine["trp"] as! [Dictionary<String, AnyObject>]).first!["icn"] as! [String]
      let lines = (bestRoutine["trp"] as! [Dictionary<String, AnyObject>]).first!["lns"] as! [String]
      
      originLabel.setText(bestRoutine["ori"] as? String)
      destinationLabel.setText(bestRoutine["des"] as? String)
      departureLabel.setText(createDepartureTimeString(bestRoutine["dep"] as! String))
      subTitleLabel.setText(bestRoutine["tit"] as? String)
      createTripIcons(icons, lines: lines)
    }
  }
  
  /**
   * Displays an error
   */
  override func displayError(title: String, message: String?) {
    subTitleLabel.setText(title)
    subTitleLabel.setTextColor(UIColor.redColor())
  }
  
  /**
   * Updates UI to show "Loading..."
   */
  override func setLoadingUIState() {
    contentGroup.setHidden(true)
    subTitleLabel.setText("Söker resa...")
    subTitleLabel.setTextColor(UIColor.lightGrayColor())
  }
  
  /**
   * Updates UI to show content
   */
  override func showContentUIState() {
    if let data = routineData {
      let bestRoutine = data["best"] as! Dictionary<String, AnyObject>
      contentGroup.setHidden(false)
      subTitleLabel.setText(bestRoutine["tit"] as? String)
      subTitleLabel.setTextColor(UIColor.whiteColor())
    }
  }
}
