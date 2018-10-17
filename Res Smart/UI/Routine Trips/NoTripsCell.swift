//
//  NoTripsCell.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2017-09-03.
//  Copyright © 2017 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit
import ResStockholmApiKit

class NoTripsCell: UITableViewCell {
    
    @IBOutlet weak var routineTitleLabel: UILabel!
    
    /**
     * Populate cell data based on passed RoutineTrip
     */
    func setupData(_ routineTrip: RoutineTrip) {
        routineTitleLabel.text = routineTrip.title
    }
}
