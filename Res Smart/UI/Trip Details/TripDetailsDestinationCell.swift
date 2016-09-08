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
  func setData(indexPath: NSIndexPath, trip: Trip) {
    let segment = trip.tripSegments[indexPath.section]
    timeLabel.text = DateUtils.dateAsTimeString(segment.arrivalDateTime)
    timeLabel.accessibilityLabel = "Framme \(timeLabel.text!)"
    destinationLabel.text = segment.destination.cleanName
    if segment.exitText != "" {
      exitLabel.text = "Uppgång: \(segment.exitText)"
    }
    destinationLabel.accessibilityLabel = "vid \(destinationLabel.text!)"
  }
}