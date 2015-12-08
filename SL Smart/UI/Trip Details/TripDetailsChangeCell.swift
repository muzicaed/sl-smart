//
//  TripDetailsChangeCell.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-12-08.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit

class TripDetailsChangeCell: UITableViewCell, TripCellProtocol {
  
  @IBOutlet weak var arrivalTimeLabel: UILabel!
  @IBOutlet weak var destinationLabel: UILabel!
  @IBOutlet weak var departureTimeLabel: UILabel!
  @IBOutlet weak var originLabel: UILabel!
  
  
  
  func setData(indexPath: NSIndexPath, trip: Trip) {
    // Set data here
  }
}