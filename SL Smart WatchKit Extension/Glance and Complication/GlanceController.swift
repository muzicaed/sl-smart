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
  
  /**
   * Updates UI if no trips was found
   * for best routine.
   */
  override func updateUINoTripsFound(bestRoutine: Dictionary<String, AnyObject>) {
    subTitleLabel.setText(bestRoutine["tit"] as? String)
    departureLabel.setText("Ingen resa")
    originLabel.setText("")
    destinationLabel.setText("")
    contentGroup.setHidden(false)
    for (index, _) in icons.enumerate() {
      iconGroups[index].setHidden(true)
    }
  }
  
  /**
   * Updates UI using data from iPhone
   */
  override func updateUIData() {
    if let data = routineData {
      let bestRoutine = data["best"] as! Dictionary<String, AnyObject>
      let icons = (bestRoutine["trp"] as! [Dictionary<String, AnyObject>]).first!["icn"] as! [String]
      let lines = (bestRoutine["trp"] as! [Dictionary<String, AnyObject>]).first!["lns"] as! [String]
      
      updateDepatureUI()
      subTitleLabel.setText(bestRoutine["tit"] as? String)
      originLabel.setText(bestRoutine["ori"] as? String)
      destinationLabel.setText(bestRoutine["des"] as? String)
      departureLabel.setText(currentDepartureText)
      createTripIcons(icons, lines: lines)
    }
  }
  
  /**
   * Updates UI for departure time.
   */
  override func updateDepatureUI() {
    if let data = routineData {
      let bestRoutine = data["best"] as! Dictionary<String, AnyObject>
      currentDepartureText = DateUtils.createDepartureTimeString(
        bestRoutine["dep"] as! String, isWalk: checkIfWalk(bestRoutine))
      departureLabel.setText(currentDepartureText)
      return
    }
    // Retry after 1.5 seconds...
    retryTimer = NSTimer.scheduledTimerWithTimeInterval(
      NSTimeInterval(1.5), target: self, selector: "forceRefreshData", userInfo: nil, repeats: false)
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
      if !isLoading {
        updateUIData()
        let bestRoutine = data["best"] as! Dictionary<String, AnyObject>
        contentGroup.setHidden(false)
        subTitleLabel.setText(bestRoutine["tit"] as? String)
        subTitleLabel.setTextColor(UIColor.whiteColor())
      }
    }
  }
  
  // MARK: Private
  
  /**
  * Hides live data when user leaves glance or lock screen.
  * We do this to not have the view displaying old data
  * for a second, when UI is reloaded when the glance
  * is reactivaed.
  */
  override func hideLiveData() {
    isLoading = false
    if let text = currentDepartureText {
      if text.rangeOfString("Om") != nil {
        departureLabel.setText("Uppdaterar")
      }
    }
  }
}
