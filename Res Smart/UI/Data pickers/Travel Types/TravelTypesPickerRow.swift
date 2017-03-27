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
      tripTypeLabel.text = "Alla färdmedel".localized
      return
    }
    
    var text = ""
    if criterions.useMetro {
      text += "\("Tunnelbana".localized), "
    }
    if criterions.useTrain {
      text += "\("Pendeltåg".localized), "
    }
    if criterions.useTram {
      text += "\("Spårvagn".localized), "
    }
    if criterions.useBus {
      text += "\("Buss".localized), "
    }
    if criterions.useFerry {
      text += "\("Båt".localized), "
    }
    
    if text == "" {
      tripTypeLabel.text = "Inga färdmedel".localized
      tripTypeLabel.textColor = UIColor.red
      return
    }
    text = text.substring(to: text.index(before: text.characters.index(before: text.endIndex)))
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
