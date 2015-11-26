//
//  TripCell.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-26.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit

class TripCell: UICollectionViewCell {
  
  @IBOutlet weak var originLabel: UILabel!
  @IBOutlet weak var destinationLabel: UILabel!
  @IBOutlet weak var departureTimeLabel: UILabel!
  @IBOutlet weak var arrivalTimeLabel: UILabel!
  @IBOutlet weak var iconAreaView: UIView!
  @IBOutlet weak var tripDurationLabel: UILabel!
  
  /**
   * Populate cell data based on passed RoutineTrip
   */
  func setupData(trip: Trip) {
    originLabel.text = trip.tripSegments.first?.origin.cleanName
    destinationLabel.text = trip.tripSegments.last?.destination.cleanName
    if trip.tripSegments.count > 0 {
      let trip = trip
      departureTimeLabel.text = Utils.dateAsTimeString(
        trip.tripSegments.first!.departureDateTime)
      arrivalTimeLabel.text = Utils.dateAsTimeString(
        trip.tripSegments.last!.arrivalDateTime)
      tripDurationLabel.text = "Restid: \(trip.durationMin) min"
      createTripSegmentIcons(trip)
    }
  }
  
  // MARK: Private methods
  
  /**
   * Creates trip type icon per segment.
   */
  private func createTripSegmentIcons(trip: Trip) {
    iconAreaView.subviews.forEach({ $0.removeFromSuperview() })
    
    for (index, segment) in trip.tripSegments.enumerate() {
      if index > 5 { return }
      let data = TripHelper.friendlyLineData(segment)
      
      let iconView = UIImageView(image: UIImage(named: data.icon))
      iconView.frame.size = CGSizeMake(15, 15)
      iconView.center = CGPointMake(23 / 2, 9)
      
      let label = UILabel()
      label.text = data.short
      label.textAlignment = NSTextAlignment.Center
      label.font = UIFont.systemFontOfSize(6.5)
      label.textColor = UIColor.darkGrayColor()
      label.sizeToFit()
      label.frame.size.width = 28
      label.center = CGPointMake((23 / 2), 21)
      label.adjustsFontSizeToFitWidth = true
      
      let wrapperView = UIView(
        frame:CGRect(
          origin: CGPointMake(0, 0),
          size: CGSizeMake(23, 30)))
      wrapperView.frame.origin = CGPointMake((23 * CGFloat(index)), 0)
      
      wrapperView.addSubview(iconView)
      wrapperView.addSubview(label)
      wrapperView.clipsToBounds = false
      iconAreaView.addSubview(wrapperView)
    }
  }
}