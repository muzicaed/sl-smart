//
//  RoutineTripCell.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-20.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit
import ResStockholmApiKit

class RoutineTripCell: UICollectionViewCell {
  
  
  @IBOutlet weak var arrowLabel: UILabel!
  
  @IBOutlet weak var tripTitleLabel: UILabel!
  @IBOutlet weak var originLabel: UILabel!
  @IBOutlet weak var destinationLabel: UILabel!
  @IBOutlet weak var departureTimeLabel: UILabel!
  @IBOutlet weak var arrivalTimeLabel: UILabel!
  @IBOutlet weak var iconAreaView: UIView!
  @IBOutlet weak var tripDurationLabel: UILabel!
  @IBOutlet weak var inAboutLabel: UILabel!
  @IBOutlet weak var nextInAboutLabel: UILabel!
  
  @IBOutlet weak var advancedView: UIView!
  @IBOutlet weak var advancedLabel: UILabel!
  
  let normalColor = UIColor(red: 63/255, green: 73/255, blue: 62/255, alpha: 0.6)
  
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
    layer.masksToBounds = false
    layer.shadowOffset = CGSizeMake(1, 1)
    layer.shadowRadius = 2.0
    layer.shadowColor = UIColor.blackColor().CGColor
    layer.shadowOpacity = 0.15
    layer.cornerRadius = 4.0
    clipsToBounds = false
  }
  
  /**
   * Populate cell data based on passed RoutineTrip
   */
  func setupData(routineTrip: RoutineTrip, isBest: Bool) {
    var title = routineTrip.title!
    if routineTrip.isSmartSuggestion {
      title = "\(routineTrip.criterions.origin!.cleanName) - \(routineTrip.criterions.dest!.cleanName)"
      title += NSLocalizedString(" (Vana)", comment: "")
    }
    
    tripTitleLabel.text = title //+ " [\(String(routineTrip.score))]"
    originLabel.text = routineTrip.criterions.origin?.cleanName
    destinationLabel.text = routineTrip.criterions.dest?.cleanName
    
    if let trip = routineTrip.trips.first {
      var second: Trip? = nil
      if routineTrip.trips.count > 1 && isBest {
        second = routineTrip.trips[1]
      }
      setupTripData(trip, secondTrip: second)
    } else if isBest {
      setNoTripsUI()
    }
    advancedLabel.text = AdvancedCriterionsHelper.createAdvCriterionText(routineTrip.criterions)
  }
  
  /**
   * Highlight this cell
   */
  func highlight() {
    self.backgroundColor = StyleHelper.sharedInstance.mainGreen
  }
  
  /**
   * Unhighlight this cell
   */
  func unhighlight() {
    self.backgroundColor = normalColor
  }
  
  // MARK: Private methods
  
  private func setupTripData(trip: Trip, secondTrip: Trip?) {
    nextInAboutLabel.hidden = true
    arrowLabel.hidden = false
    if let first = trip.tripSegments.first, last = trip.tripSegments.last  {
      departureTimeLabel.text = DateUtils.dateAsTimeString(first.departureDateTime)
      arrivalTimeLabel.text = DateUtils.dateAsTimeString(last.arrivalDateTime)
      inAboutLabel.text = DateUtils.createAboutTimeText(
        first.departureDateTime, isWalk: first.type == TripType.Walk)
      
      tripDurationLabel.text = DateUtils.createTripDurationString(trip.durationMin)
      
      createTripSegmentIcons(trip)
    }
    
    if let second = secondTrip?.tripSegments.first, first = trip.tripSegments.first {
      let depTimeInterval = first.departureDateTime.timeIntervalSinceNow
      if depTimeInterval < (60 * 11) {
        let diffMin = Int(ceil(((second.departureDateTime.timeIntervalSince1970 - NSDate().timeIntervalSince1970) / 60)) + 0.5)
        if diffMin <= 60 {
          nextInAboutLabel.text = String(format: NSLocalizedString("Nästa: %d min", comment: ""), diffMin)
          nextInAboutLabel.hidden = false
        }
      }
    }
  }
  
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
        iconView.center = CGPointMake(30 / 2, 3)
        
        let label = UILabel()
        label.text = "\u{200A}\(data.short)\u{200A}"
        label.textAlignment = NSTextAlignment.Center
        label.font = UIFont.boldSystemFontOfSize(10)
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        label.textColor = UIColor.whiteColor()
        label.backgroundColor = data.color
        label.frame.size.width = 18
        label.frame.size.height = 18
        label.center = CGPointMake((30 / 2), 23)
        label.layer.cornerRadius = 2
        label.clipsToBounds = true
        
        let wrapperView = UIView(
          frame:CGRect(
            origin: CGPointMake(0, 0),
            size: CGSizeMake(18, 36)))
        wrapperView.frame.origin = CGPointMake((20 * CGFloat(count)), 0)
        wrapperView.clipsToBounds = false
        
        wrapperView.addSubview(iconView)
        wrapperView.addSubview(label)
        
        if segment.rtuMessages != nil {
          var warnIconView = UIImageView(image: TripIcons.icons["INFO-ICON"]!)
          if segment.isWarning {
            warnIconView = UIImageView(image: TripIcons.icons["WARNING-ICON"]!)
          }
          warnIconView.frame.size = CGSizeMake(10, 10)
          warnIconView.center = CGPointMake((30 / 2) + 6, -4)
          warnIconView.alpha = 0.85
          wrapperView.insertSubview(warnIconView, aboveSubview: iconView)
        }
        
        iconAreaView.addSubview(wrapperView)
        count += 1
      }
    }
  }
  
  
  /**
   * Sets no trips found UI
   */
  private func setNoTripsUI() {
    iconAreaView.subviews.forEach({ $0.removeFromSuperview() })
    departureTimeLabel.text = "--:--"
    arrivalTimeLabel.text = "--:--"
    inAboutLabel.text = ""
    
    tripDurationLabel.text = NSLocalizedString("Hittade ingen resa...", comment: "")
  }
}