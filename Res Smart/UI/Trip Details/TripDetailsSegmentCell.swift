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

class TripDetailsSegmentCell: UITableViewCell {
  
  @IBOutlet weak var tripTypeIcon: UIImageView!
  @IBOutlet weak var lineLabel: UILabel!
  @IBOutlet weak var directionLabel: UILabel!
  @IBOutlet weak var arrowLabel: UILabel!
  @IBOutlet weak var warningLabel: UILabel!
  
  /**
   * Set cell data.
   */
  func setData(indexPath: NSIndexPath,
    visual: (isVisible: Bool, hasStops: Bool), trip: Trip) {
      let segment = trip.tripSegments[indexPath.section]
      let lineData = TripHelper.friendlyLineData(segment)
      tripTypeIcon.image = UIImage(named: lineData.icon)
      lineLabel.text = lineData.long
      directionLabel.text = TripHelper.friendlyTripSegmentDesc(segment)
      warningLabel.text = segment.rtuMessages
      
      if warningLabel.text == nil {
        warningLabel.hidden = true
      }
            
      if segment.type == .Walk {
        lineLabel.hidden = true
        warningLabel.hidden = true
      }
      updateStops(visual)
  }
  
  /**
   * Update state based on stops
   */
  func updateStops(visual: (isVisible: Bool, hasStops: Bool)) {
    arrowLabel.hidden = true
    if visual.hasStops {
      userInteractionEnabled = true
      selectionStyle = .Default
      arrowLabel.hidden = false
      if visual.isVisible {
        arrowLabel.text = "▲"
      } else {
        arrowLabel.text = "▼"
      }
    }
  }
}