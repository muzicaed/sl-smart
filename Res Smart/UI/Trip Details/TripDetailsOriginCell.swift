//
//  TripDetailsOriginCell.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-12-08.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit
import ResStockholmApiKit

class TripDetailsOriginCell: UITableViewCell, TripCellProtocol {
  
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var locationLabel: UILabel!
  
  /**
   * Set cell data.
   */
  func setData(indexPath: NSIndexPath, trip: Trip) {
    let segment = trip.tripSegments[indexPath.section]
    timeLabel.text = DateUtils.dateAsTimeString(segment.departureDateTime)
    timeLabel.accessibilityLabel = "Avgång \(timeLabel.text!)"
    locationLabel.text = segment.origin.cleanName
    locationLabel.accessibilityLabel = "från \(locationLabel.text!)"
    locationLabel.textColor = UIColor.blackColor()
  }

}