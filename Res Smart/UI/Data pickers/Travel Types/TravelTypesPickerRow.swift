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
            tripTypeLabel.text = "All transport modes".localized
            return
        }
        
        var text = ""
        if criterions.useMetro {
            text += "\("Metro".localized), "
        }
        if criterions.useTrain {
            text += "\("Trains".localized), "
        }
        if criterions.useTram {
            text += "\("Tram".localized), "
        }
        if criterions.useBus {
            text += "\("Bus".localized), "
        }
        if criterions.useFerry {
            text += "\("Boat".localized), "
        }
        
        if text == "" {
            tripTypeLabel.text = "No transport modes".localized
            tripTypeLabel.textColor = UIColor.red
            return
        }
        
        let index = text.index(text.endIndex, offsetBy: -2)
        tripTypeLabel.text = String(text[..<index])
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
