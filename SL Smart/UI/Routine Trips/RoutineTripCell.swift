//
//  RoutineTripCell.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-20.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit

class RoutineTripCell: UICollectionViewCell {
  
  @IBOutlet weak var tripTitleLabel: UILabel!
  @IBOutlet weak var tripLabel: UILabel!
  @IBOutlet weak var departureTimeLabel: UILabel!
  @IBOutlet weak var arrivalTimeLabel: UILabel!
  
  override init(frame: CGRect) {
    super.init(frame: frame)
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
    layer.borderColor = UIColor.whiteColor().CGColor
    layer.cornerRadius = 6
    layer.borderWidth = 4
  }
  
  /**
   * Populate cell data based on passed RoutineTrip
   */
  func setupData(trip: RoutineTrip) {
    tripTitleLabel.text = trip.title!
    tripLabel.text = "\(trip.origin!.name)  →  \(trip.destination!.name)" 
  }
}