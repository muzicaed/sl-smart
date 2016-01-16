//
//  TripDetailsSubSegmentCell.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-01-16.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import ResStockholmApiKit

class TripDetailsSubSegmentCell: UITableViewCell, TripCellProtocol {
  
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var locationLabel: UILabel!
  
  /**
   * Set cell data.
   */
  func setData(indexPath: NSIndexPath, trip: Trip) {
    let stop = trip.tripSegments[indexPath.section].stops[indexPath.row - 2]
    locationLabel.text = stop.name
    if let date = stop.depDate {
      timeLabel.text = DateUtils.dateAsTimeString(date)
    }
  }
}