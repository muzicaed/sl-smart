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
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }
  
  /**
   * Shared init code.
   */
  func setup() {
    layer.masksToBounds = false
    layer.shadowOffset = CGSize(width: 0, height: 1)
    layer.shadowRadius = 1.0
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOpacity = 0.15
    clipsToBounds = false
  }
  
  /**
   * Set cell data.
   */
  func setData(_ indexPath: IndexPath, trip: Trip) {
    let segment = trip.tripSegments[indexPath.section]
    timeLabel.text = DateUtils.dateAsTimeString(segment.arrivalDateTime)
    timeLabel.accessibilityLabel = "Framme \(timeLabel.text!)"
    destinationLabel.text = segment.destination.cleanName
    exitLabel.text = ""
    if segment.exitText != "" {
      exitLabel.text = "⤴ \(segment.exitText)"
    }
    destinationLabel.accessibilityLabel = "vid \(destinationLabel.text!)"
  }
}
