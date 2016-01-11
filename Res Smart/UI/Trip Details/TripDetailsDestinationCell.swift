//
//  TripDetailsDestinationCell.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-12-08.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit
import ResStockholmApiKit

class TripDetailsDestinationCell: UITableViewCell, TripCellProtocol {
  
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var destinationLabel: UILabel!
  
  /**
   * Set cell data.
   */
  func setData(indexPath: NSIndexPath, trip: Trip) {
    timeLabel.text = DateUtils.dateAsTimeString(trip.tripSegments.last!.arrivalDateTime)
    destinationLabel.text = trip.tripSegments.last!.destination.cleanName
  }
}