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
  @IBOutlet weak var iconAreaView: UIView!
  
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
  func setupData(routineTrip: RoutineTrip) {
    tripTitleLabel.text = routineTrip.title!
    tripLabel.text = "\(routineTrip.origin!.name)  →  \(routineTrip.destination!.name)"
    if routineTrip.trip.tripSegments.count > 0 {
      let bestTrip = routineTrip.trip
      departureTimeLabel.text = Utils.dateAsTimeString(
        bestTrip.tripSegments.first!.departureDateTime)
      arrivalTimeLabel.text = Utils.dateAsTimeString(
        bestTrip.tripSegments.last!.arrivalDateTime)
      
      createTripSegmentIcons(bestTrip)
    }
  }
  
  // MARK: Private methods
  
  
  /**
   * Creates trip type icon per segment.
   */
  private func createTripSegmentIcons(trip: Trip) {
    iconAreaView.subviews.forEach({ $0.removeFromSuperview() })
    print("Trip count \(trip.tripSegments.count)")
    for (index, segment) in trip.tripSegments.reverse().enumerate() {
      let iconName = TripHelper.buildSegmentIconName(segment)
      let iconView = UIImageView(image: UIImage(named: iconName))

      iconView.frame.size = CGSizeMake(20, 20)
      iconView.center = CGPointMake((25 * CGFloat(index) + 38), iconAreaView.center.y)
      iconAreaView.addSubview(iconView)
    }
  }
}