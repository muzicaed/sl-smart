//
//  TripDetailsDestinationCell.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-12-08.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit

class TripDetailsDestinationCell: UITableViewCell, TripCellProtocol {
  
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var destinationLabel: UILabel!
    
  func setData(indexPath: NSIndexPath, trip: Trip) {
    // Set data here
  }
}