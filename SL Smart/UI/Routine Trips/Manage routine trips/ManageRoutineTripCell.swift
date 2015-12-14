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
    createAdvancedText(routineTrip)
  }
  
  // MARK: Private
  
  
  /**
   * Creates text for advanced label based on anvanced
   * trip options.
   */
  func createAdvancedText(routineTrip: RoutineTrip) {
    var text = "Inga avancerade inställningar"
    if let via = routineTrip.criterions.via {
      text = "Via \(via.name)"
      advancedLabel.textColor = UIColor.darkGrayColor()      
    }
    
    advancedLabel.text = text
  }
}