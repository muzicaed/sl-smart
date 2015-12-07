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
  
  override init() {
    super.init()
  }
  
  /**
   * Updates UI using data from iPhone
   */
  override func updateUIData() {
    print("GlanceController updateUIData")
    if let data = routineData {
      originLabel.setText(data["ori"] as? String)
      destinationLabel.setText(data["des"] as? String)
      departureLabel.setText(createDepartureTimeString(data["dep"] as! String))
      subTitleLabel.setText(data["tit"] as? String)
      createTripIcons(data["icn"] as! [String])
    }
  }
  
  /**
   * Displays an error
   */
  override func displayError(title: String, message: String?) {
    print("GlanceController displayError")
    subTitleLabel.setText(title)
    subTitleLabel.setTextColor(UIColor.redColor())
  }
  
  /**
   * Updates UI to show "Loading..."
   */
  override func setLoadingUIState() {
    print("GlanceController setLoadingUIState")
    contentGroup.setHidden(true)
    subTitleLabel.setText("Söker resa...")
    subTitleLabel.setTextColor(UIColor.lightGrayColor())
  }
  
  /**
   * Updates UI to show content
   */
  override func showContentUIState() {
    print("GlanceController showContentUIState")
    if let data = routineData {
      contentGroup.setHidden(false)
      subTitleLabel.setText(data["tit"] as? String)
      subTitleLabel.setTextColor(UIColor.whiteColor())
    }
  }
}
