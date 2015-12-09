//
//  TripDetailsSegmentCell.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-12-08.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit
import ResStockholmApiKit

class TripDetailsSegmentCell: UITableViewCell, TripCellProtocol {
  
  @IBOutlet weak var tripTypeIcon: UIImageView!
  @IBOutlet weak var lineLabel: UILabel!
  @IBOutlet weak var directionLabel: UILabel!
  
  /**
   * Set cell data.
   */
  func setData(indexPath: NSIndexPath, trip: Trip) {
    let segment = trip.tripSegments[indexPath.section - 1]
    let lineData = TripHelper.friendlyLineData(segment)
    tripTypeIcon.image = UIImage(named: lineData.icon)
    lineLabel.text = lineData.long
    directionLabel.text = TripHelper.friendlyTripSegmentDesc(segment)
    
    if segment.type == .Walk {
      lineLabel.hidden = true
    }
  }
}