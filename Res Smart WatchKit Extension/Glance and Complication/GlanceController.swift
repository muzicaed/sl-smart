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
  override func updateUINoTripsFound(_ bestRoutine: Dictionary<String, AnyObject>) {

    subTitleLabel.setText(bestRoutine["ti"] as? String)
    departureLabel.setText("No trips")
    originLabel.setText("")
    destinationLabel.setText("")
    contentGroup.setHidden(false)
    for (index, _) in icons.enumerated() {
      iconGroups[index].setHidden(true)
    }
  }
  
  /**
   * Updates UI using data from iPhone
   */
  override func updateUIData() {
    if let data = routineData {
      let bestRoutine = data["b"] as! Dictionary<String, AnyObject>
      let icons = (bestRoutine["tr"] as! [Dictionary<String, AnyObject>]).first!["icn"] as! [String]
      let lines = (bestRoutine["tr"] as! [Dictionary<String, AnyObject>]).first!["lns"] as! [String]
      let warnings = (bestRoutine["tr"] as! [Dictionary<String, AnyObject>]).first!["war"] as! [String]
      
      updateDepatureUI()

      subTitleLabel.setText(bestRoutine["ti"] as? String)
      originLabel.setText(bestRoutine["or"] as? String)
      destinationLabel.setText(bestRoutine["ds"] as? String)
      departureLabel.setText(currentDepartureText)
      createTripIcons(icons, lines: lines, warnings: warnings)
    }
  }
  
  /**
   * Updates UI for departure time.
   */
  override func updateDepatureUI() {
    if let data = routineData {
      let bestRoutine = data["b"] as! Dictionary<String, AnyObject>
      currentDepartureText = DateUtils.createDepartureTimeString(
        bestRoutine["dp"] as! String, isWalk: checkIfWalk(bestRoutine))
      departureLabel.setText(currentDepartureText)
      return
    }
    // Retry after 1.5 seconds...
    retryTimer = Timer.scheduledTimer(
      timeInterval: TimeInterval(1.5), target: self, selector: #selector(forceRefreshData),
      userInfo: nil, repeats: false)
  }
  
  /**
   * Displays an error
   */
  override func displayError(_ title: String, message: String?) {
    subTitleLabel.setText(title)
    subTitleLabel.setTextColor(UIColor.red)
    isLoading = false
  }
  
  /**
   * Updates UI to show "Loading..."
   */
  override func setLoadingUIState() {
    contentGroup.setHidden(true)
    subTitleLabel.setText("Searching...")
    subTitleLabel.setTextColor(UIColor.lightGray)
  }
  
  /**
   * Updates UI to show content
   */
  override func showContentUIState() {
    if let data = routineData {
      if !isLoading {
        updateUIData()
        let bestRoutine = data["b"] as! Dictionary<String, AnyObject>
        contentGroup.setHidden(false)
        subTitleLabel.setText(bestRoutine["ti"] as? String)
        subTitleLabel.setTextColor(UIColor.white)
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
      if text.range(of: "Om") != nil {
        departureLabel.setText("Updating")
      }
    }
  }
}
