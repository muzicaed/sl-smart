//
//  TripDetailsOriginCell.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-12-08.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit

class TripDetailsOriginCell: UITableViewCell, TripCellProtocol {
  
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var locationLabel: UILabel!
  
  /**
   * Set cell data.
   */
  func setData(indexPath: NSIndexPath, trip: Trip) {
    timeLabel.text = DateUtils.dateAsTimeString(trip.tripSegments.first!.departureDateTime)
    locationLabel.text = trip.tripSegments.first!.origin.name
  }
  
}