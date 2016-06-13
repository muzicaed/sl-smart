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
  @IBOutlet weak var segmentIcon: UIImageView!
  @IBOutlet weak var summaryLabel: UILabel!
  
  /**
   * Set cell data.
   */
  func setData(
    indexPath: NSIndexPath, visual: (isVisible: Bool, hasStops: Bool), trip: Trip) {
    
    let segment = trip.tripSegments[indexPath.section]
    let lineData = TripHelper.friendlyLineData(segment)
    tripTypeIcon.image = UIImage(named: lineData.icon)
    lineLabel.text = lineData.long
    lineLabel.textColor = lineData.color
    directionLabel.text = TripHelper.friendlyTripSegmentDesc(segment)
    summaryLabel.text = createSummary(segment)
    warningLabel.text = segment.rtuMessages
    warningLabel.hidden = false
    
    if warningLabel.text == nil {
      warningLabel.hidden = true
    } else if !segment.isWarning {
      warningLabel.textColor = UIColor(red: 39/255, green: 44/255, blue: 211/255, alpha: 1.0)
    }
    
    if segment.type == .Walk {
      lineLabel.hidden = true
      warningLabel.hidden = true
    }
    updateStops(visual)
    segmentIcon.frame.size.height += contentView.bounds.size.height + 1
  }
  
  /**
   * Update state based on stops
   */
  func updateStops(visual: (isVisible: Bool, hasStops: Bool)) {
    arrowLabel.text = ""
    arrowLabel.isAccessibilityElement = false
    if visual.hasStops {
      userInteractionEnabled = true
      selectionStyle = .Default
      if visual.isVisible {
        arrowLabel.text = "▲"
      } else {
        arrowLabel.text = "▼"
      }
    }
  }
  
  /**
   * Generates a summary text for segment.
   */
  private func createSummary(segment: TripSegment) -> String {
    print(segment.stops)
    if segment.stops.count > 0 {
      return "\(segment.stops.count + 1) hållplatser (\(segment.durationInMin) minuter)"
    }
    
    return "1 hållplats (\(segment.durationInMin) minuter)"
  }
}