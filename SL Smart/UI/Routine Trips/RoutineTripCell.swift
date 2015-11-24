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
  @IBOutlet weak var originLabel: UILabel!
  @IBOutlet weak var destinationLabel: UILabel!
  @IBOutlet weak var departureTimeLabel: UILabel!
  @IBOutlet weak var arrivalTimeLabel: UILabel!
  @IBOutlet weak var iconAreaView: UIView!
  @IBOutlet weak var tripDurationLabel: UILabel!
  
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
    originLabel.text = routineTrip.origin?.name
    destinationLabel.text = routineTrip.destination?.name
    if routineTrip.trip.tripSegments.count > 0 {
      let bestTrip = routineTrip.trip
      departureTimeLabel.text = Utils.dateAsTimeString(
        bestTrip.tripSegments.first!.departureDateTime)
      arrivalTimeLabel.text = Utils.dateAsTimeString(
        bestTrip.tripSegments.last!.arrivalDateTime)
      tripDurationLabel.text = "Restid: \(bestTrip.durationMin) min"
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
    for (index, segment) in trip.tripSegments.enumerate() {
      let iconName = TripHelper.buildSegmentIconName(segment)
      let iconView = UIImageView(image: UIImage(named: iconName))

      iconView.frame.size = CGSizeMake(15, 15)
      iconView.frame.origin = CGPointMake((20 * CGFloat(index)), 0)
      iconAreaView.addSubview(iconView)
      iconAreaView.sizeToFit()
    }
  }
}