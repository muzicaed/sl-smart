//
//  TravelTypesPickerRow.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-12-14.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit
import ResStockholmApiKit

class TravelTypesPickerRow: UITableViewCell {
  
  @IBOutlet var tripTypeLabel: UILabel!
  
  /**
   * Update the text label based on criterions.
   */
  func updateLabel(_ criterions: TripSearchCriterion) {
    tripTypeLabel.textColor = UIColor.darkGray
    if isAllSelected(criterions) {
      tripTypeLabel.text = "Alla färdmedel"
      return
    }
    
    var text = ""
    if criterions.useMetro {
      text += "Tunnelbana, "
    }
    if criterions.useTrain {
      text += "Pendeltåg, "
    }
    if criterions.useTram {
      text += "Spårvagn, "
    }
    if criterions.useBus {
      text += "Buss, "
    }
    if criterions.useFerry {
      text += "Båt, "
    }
    
    if text == "" {
      tripTypeLabel.text = "Inga färdmedel"
      tripTypeLabel.textColor = UIColor.red
      return
    }
    text = text.substring(to: <#T##Collection corresponding to your index##Collection#>.index(before: text.characters.index(before: text.endIndex)))
    tripTypeLabel.text = text
  }
  
  
  // MARK: Private
  
  /**
  * Checks if all travel types are selected.
  */
  fileprivate func isAllSelected(_ criterions: TripSearchCriterion) -> Bool {
    return (
      criterions.useBus && criterions.useFerry && criterions.useMetro &&
        criterions.useShip && criterions.useTrain && criterions.useTram)
  }
}
