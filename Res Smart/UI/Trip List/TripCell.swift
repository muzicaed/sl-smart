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
  func setupData(_ trip: Trip) {
    if trip.tripSegments.count > 0 {
      let trip = trip
      departureTimeLabel.textColor = StyleHelper.sharedInstance.mainGreen
      departureTimeLabel.text = DateUtils.dateAsTimeString(
        trip.tripSegments.first!.departureDateTime)
      
      arrivalTimeLabel.textColor = StyleHelper.sharedInstance.mainGreen
      arrivalTimeLabel.text = DateUtils.dateAsTimeString(
        trip.tripSegments.last!.arrivalDateTime)
      
      let aboutTime = DateUtils.createAboutTimeText(
        trip.tripSegments.first!.departureDateTime,
        isWalk: trip.tripSegments.first!.type == TripType.Walk)
      if aboutTime != "" {
        inAboutLabel.text = " \(aboutTime) \u{200C}"
        inAboutLabel.layer.backgroundColor = UIColor.darkGray.cgColor
        inAboutLabel.layer.cornerRadius = 4.0
        inAboutLabel.textColor = UIColor.white
        inAboutLabel.isHidden = false
      } else {
        inAboutLabel.isHidden = true
      }
      
      if trip.isValid {
        tripDurationLabel.text = DateUtils.createTripDurationString(trip.durationMin)
      }
      
      createTripSegmentIcons(trip)
    }
  }
  
  // MARK: Private methods
  
  /**
   * Creates trip type icon per segment.
   * TODO: Refactoring merge with RoutineTripCell.createTripSegmentIcons()
   */
  fileprivate func createTripSegmentIcons(_ trip: Trip) {
    iconAreaView.subviews.forEach({ $0.removeFromSuperview() })
    var count = 0
    for (_, segment) in trip.tripSegments.enumerated() {
      if segment.type != .Walk || (segment.type == .Walk && segment.distance! > 30) {
        if count >= 6 { return }
        let data = TripHelper.friendlyLineData(segment)
        
        let iconView = UIImageView(image: TripIcons.icons[data.icon]!)
        iconView.frame.size = CGSize(width: 22, height: 23)
        iconView.center = CGPoint(x: 22 / 2, y: 5)
        
        let label = UILabel()
        label.text = "\u{200A}\(data.short)\u{200A}\u{200C}"
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont.boldSystemFont(ofSize: 9)
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        label.textColor = UIColor.white
        label.layer.backgroundColor = data.color.cgColor
        label.frame.size.width = 22
        label.frame.size.height = 12
        label.center = CGPoint(x: (22 / 2), y: 22)
        label.isAccessibilityElement = false
        
        let wrapperView = UIView(
          frame:CGRect(
            origin: CGPoint(x: 0, y: 0),
            size: CGSize(width: 22, height: 39)))
        wrapperView.frame.origin = CGPoint(x: (26 * CGFloat(count)), y: 0)
        wrapperView.clipsToBounds = false
        
        wrapperView.addSubview(iconView)
        wrapperView.addSubview(label)
        
        if segment.rtuMessages != nil {
          var warnIconView = UIImageView(image: TripIcons.icons["INFO-ICON"]!)
          if segment.isWarning {
            warnIconView = UIImageView(image: TripIcons.icons["WARNING-ICON"]!)
          }
          warnIconView.frame.size = CGSize(width: 10, height: 10)
          warnIconView.center = CGPoint(x: (22 / 2) + 10, y: -5)
          warnIconView.alpha = 0.9
          wrapperView.insertSubview(warnIconView, aboveSubview: iconView)
          if segment.isWarning {
            UIView.animate(withDuration: 0.6, delay: 0, options: [.repeat, .autoreverse], animations: {
              warnIconView.alpha = 0.3
            }, completion: nil)
          }
        }
        
        iconAreaView.addSubview(wrapperView)
        count += 1
      }
    }
  }
}
