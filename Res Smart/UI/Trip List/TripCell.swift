//
//  TripCell.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-26.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit
import ResStockholmApiKit

class TripCell: UITableViewCell {
  
  @IBOutlet weak var originLabel: UILabel!
  @IBOutlet weak var destinationLabel: UILabel!
  @IBOutlet weak var departureTimeLabel: UILabel!
  @IBOutlet weak var arrivalTimeLabel: UILabel!
  @IBOutlet weak var iconAreaView: UIView!
  @IBOutlet weak var tripDurationLabel: UILabel!
  @IBOutlet weak var inAboutLabel: UILabel!
  
  /**
   * Init
   */
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
    layer.cornerRadius = 4.0
    clipsToBounds = false
  }
  
  /**
   * Populate cell data based on passed RoutineTrip
   */
  func setupData(trip: Trip) {
    originLabel.text = trip.tripSegments.first?.origin.cleanName
    destinationLabel.text = trip.tripSegments.last?.destination.cleanName
    if trip.tripSegments.count > 0 {
      let trip = trip
      departureTimeLabel.text = DateUtils.dateAsTimeString(
        trip.tripSegments.first!.departureDateTime)
      arrivalTimeLabel.text = DateUtils.dateAsTimeString(
        trip.tripSegments.last!.arrivalDateTime)
      inAboutLabel.text = DateUtils.createAboutTimeText(
        trip.tripSegments.first!.departureDateTime,
        isWalk: trip.tripSegments.first!.type == TripType.Walk)
      
      tripDurationLabel.text = DateUtils.createTripDurationString(trip.durationMin)
      
      createTripSegmentIcons(trip)
    }
  }
  
  // MARK: Private methods
  
  /**
   * Creates trip type icon per segment.
   */
  private func createTripSegmentIcons(trip: Trip) {
    iconAreaView.subviews.forEach({ $0.removeFromSuperview() })
    var count = 0
    for (_, segment) in trip.tripSegments.enumerate() {
      if segment.type != .Walk || (segment.type == .Walk && segment.distance! > 30) {
        if count > 6 { return }
        let data = TripHelper.friendlyLineData(segment)
        
        let iconView = UIImageView(image: TripIcons.icons[data.icon]!)
        iconView.frame.size = CGSizeMake(18, 18)
        iconView.center = CGPointMake(30 / 2, 5)
        
        let label = UILabel()
        label.text = "\u{200A}\(data.short)\u{200A}"
        label.textAlignment = NSTextAlignment.Center
        label.font = UIFont.boldSystemFontOfSize(10)
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        label.textColor = UIColor.whiteColor()
        label.backgroundColor = data.color
        label.frame.size.width = 18
        label.frame.size.height = 14
        label.center = CGPointMake((30 / 2), 21)
        label.layer.cornerRadius = 1
        label.clipsToBounds = true
        
        let wrapperView = UIView(
          frame:CGRect(
            origin: CGPointMake(0, 0),
            size: CGSizeMake(18, 36)))
        wrapperView.frame.origin = CGPointMake((20 * CGFloat(count)) - 6, 0)
        wrapperView.clipsToBounds = false
        
        wrapperView.addSubview(iconView)
        wrapperView.addSubview(label)
        
        if segment.rtuMessages != nil {
          var warnIconView = UIImageView(image: TripIcons.icons["INFO-ICON"]!)
          if segment.isWarning {
            warnIconView = UIImageView(image: TripIcons.icons["WARNING-ICON"]!)
          }
          warnIconView.frame.size = CGSizeMake(10, 10)
          warnIconView.center = CGPointMake((30 / 2) + 4, 0)
          warnIconView.alpha = 0.85
          wrapperView.insertSubview(warnIconView, aboveSubview: iconView)
        }
        
        iconAreaView.addSubview(wrapperView)
        count += 1
      }
    }
  }
}