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
  @IBOutlet weak var exitLabel: UILabel!
  
  /**
   * Set cell data.
   */
  func setData(_ indexPath: IndexPath, trip: Trip) {
    layer.addBorder(edge: .bottom, color: UIColor.lightGray, thickness: 0.5)
    let segment = trip.tripSegments[indexPath.section]
    timeLabel.text = DateUtils.dateAsTimeString(segment.arrivalDateTime)
    timeLabel.accessibilityLabel = "\("Arrive at".localized) \(timeLabel.text!)"
    destinationLabel.text = segment.destination.cleanName
    exitLabel.text = ""
    if segment.exitText != "" {
      exitLabel.text = "⤴ \(segment.exitText)"
    }
    destinationLabel.accessibilityLabel = "vid \(destinationLabel.text!)"
  }
}
