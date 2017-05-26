//
//  ManageRoutineTripCell.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-21.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit
import ResStockholmApiKit

class ManageRoutineTripCell: UITableViewCell {
  
  @IBOutlet weak var tripTitleLabel: UILabel!
  @IBOutlet weak var routeTextLabel: UILabel!
  @IBOutlet weak var advancedLabel: UILabel!
  
  
  /**
   * Sets data for cell
   */
  func setData(_ routineTrip: RoutineTrip) {
    tripTitleLabel.text = routineTrip.title
    routeTextLabel.text = "\(routineTrip.criterions.origin!.cleanName) » \(routineTrip.criterions.dest!.cleanName)"
    
    let advancedText = AdvancedCriterionsHelper.createAdvCriterionText(routineTrip.criterions)
    if advancedText == "" {
      advancedLabel.textColor = UIColor.lightGray
      advancedLabel.text = "No advanced settings".localized
      return
    }
    
    advancedLabel.textColor = UIColor.darkGray
    advancedLabel.text = advancedText
  }
}
