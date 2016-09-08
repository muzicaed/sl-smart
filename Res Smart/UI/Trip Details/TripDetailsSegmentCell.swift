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
    if let posText = segment.trainPositionText {
      directionLabel.text = directionLabel.text! + ", \(posText)"
    }
    warningLabel.text = generateWarningText(segment)

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
    if segment.type == .Walk {
      return "ca. \(segment.durationInMin) min"
    } else if segment.stops.count <= 2 {
      return "1 hållplats (\(segment.durationInMin) min)"
    }
    
    return "\(segment.stops.count - 1) hållplatser (\(segment.durationInMin) min)"
  }
  
  /**
   * Generates a warning text
   */
  private func generateWarningText(segment: TripSegment) -> String? {
    var warning = (segment.rtuMessages != nil) ? segment.rtuMessages! : ""
    if segment.isCancelled {
      warning = "Inställd. " + warning
    } else if !segment.isReachable {
      warning = "Mycket kort bytestid. " + warning
    }
    return warning
  }
}