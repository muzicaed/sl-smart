//
//  RoutineTripCell.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2017-08-31.
//  Copyright © 2017 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit
import ResStockholmApiKit

class RoutineTripCell: UITableViewCell {
  
  @IBOutlet weak var routineTitleLabel: UILabel!
  @IBOutlet weak var tripPath: UILabel!
  @IBOutlet weak var departureTimeLabel: UILabel!
  @IBOutlet weak var arrivalTimeLabel: UILabel!
  @IBOutlet weak var inAboutLabel: UILabel!
  @IBOutlet weak var tripTimeLabel: UILabel!
  @IBOutlet weak var iconAreaView: UIView!
  
  /**
   * Populate cell data based on passed RoutineTrip
   */
  func setupData(_ routineTrip: RoutineTrip) {
    var title = routineTrip.title!
    if routineTrip.isSmartSuggestion {
      title = "\("Habit".localized): \(routineTrip.criterions.origin!.cleanName) - \(routineTrip.criterions.dest!.cleanName)"
    }
    routineTitleLabel.text = title
    
    if let trip = routineTrip.trips.first {
      if trip.tripSegments.count > 0 {
        tripPath.text = routineTrip.criterions.origin!.cleanName + " - " + routineTrip.criterions.dest!.cleanName
        departureTimeLabel.textColor = UIColor.black
        departureTimeLabel.text = DateUtils.dateAsTimeString(
          trip.tripSegments.first!.departureDateTime)
        
        arrivalTimeLabel.textColor = UIColor.black
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
          tripTimeLabel.text = DateUtils.createTripDurationString(trip.durationMin)
          tripTimeLabel.textColor = UIColor.darkGray
        }
        
        createTripSegmentIcons(trip)
      }
    }
  }
  
  /**
   * Sets cell style to cancelled trip
   */
  func setCancelled(_ warningText: String) {
    inAboutLabel.text = " \(warningText) \u{200C}"
    inAboutLabel.layer.backgroundColor = StyleHelper.sharedInstance.warningColor.cgColor
  }
  
  /**
   * Sets cell style to past trip
   */
  func setInPast() {
    inAboutLabel.layer.backgroundColor = UIColor.lightGray.cgColor
    arrivalTimeLabel.textColor = UIColor.lightGray
    departureTimeLabel.textColor = UIColor.lightGray
    tripTimeLabel.textColor = UIColor.lightGray
    iconAreaView.alpha = 0.5
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
        if count >= 7 { return }
        let data = TripHelper.friendlyLineData(segment)
        
        let iconView = UIImageView(image: TripIcons.icons[data.icon]!)
        iconView.frame.size = CGSize(width: 22, height: 23)
        
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
        label.frame.origin.y = 22
        label.isAccessibilityElement = false
        
        let wrapperView = UIView(
          frame:CGRect(
            origin: CGPoint(x: 0, y: 0),
            size: CGSize(width: 22, height: 35)))
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
          warnIconView.center = CGPoint(x: (22 / 2) + 10, y: 3)
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
