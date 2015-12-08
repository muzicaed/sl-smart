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
    
  /**
   * Set cell data.
   */
  func setData(indexPath: NSIndexPath, trip: Trip) {
    let beforeSegment = trip.tripSegments[indexPath.section - 2]
    let segment = trip.tripSegments[indexPath.section - 1]
    
    arrivalTimeLabel.text = DateUtils.dateAsTimeString(beforeSegment.arrivalDateTime)
    destinationLabel.text = beforeSegment.destination.name
    departureTimeLabel.text = DateUtils.dateAsTimeString(segment.departureDateTime)
    originLabel.text = segment.origin.name
  }
}