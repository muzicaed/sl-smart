
//
//  RealTimeStopPointDeviationRow.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-02-02.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation
import ResStockholmApiKit
import UIKit

class RealTimeStopPointDeviationRow: UITableViewCell {
  
  @IBOutlet weak var deviationLabel: UILabel!
  
  
  /**
   * Set data for this cell
   */
  func setData(realTimeDepartures: RealTimeDepartures?) {
    deviationLabel.textColor = StyleHelper.sharedInstance.warningColor
    deviationLabel.text = realTimeDepartures?.deviations.joined(separator: "\n\n")
    if deviationLabel.text == "" {
      deviationLabel.textColor = UIColor.black
      deviationLabel.text = "Inga trafikstörningar för denna plats."
    }
  }
}
