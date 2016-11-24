//
//  SituationRow.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-12-10.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit
import ResStockholmApiKit

class SituationRow: UITableViewCell {

  @IBOutlet weak var messageLabel: UILabel!
  
  
  /**
   * Sets data based on situation.
   */
  func setData(situation: Situation) {
    let header = (situation.trafficLine != nil) ? situation.trafficLine! + "\n" : ""
    messageLabel.text = header + situation.message
    messageLabel.accessibilityLabel = "Trafikstörning: " + situation.message
    messageLabel.textColor = StyleHelper.sharedInstance.warningColor
    accessoryType = .None
    userInteractionEnabled = false
  }
}