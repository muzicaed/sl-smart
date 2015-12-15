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
  func setData(routineTrip: RoutineTrip) {
    tripTitleLabel.text = routineTrip.title
    routeTextLabel.text = "\(routineTrip.criterions.origin!.cleanName) » \(routineTrip.criterions.dest!.cleanName)"
    
    let advancedText = AdvancedCriterionsHelper.createAdvCriterionText(routineTrip.criterions)
    print(advancedText)
    if advancedText == "" {
      advancedLabel.textColor = UIColor.lightGrayColor()
      advancedLabel.text = "Inga advancerade inställningar"
      return
    }
    
    advancedLabel.textColor = UIColor.darkGrayColor()
    advancedLabel.text = advancedText
  }
  
  // MARK: Private
}