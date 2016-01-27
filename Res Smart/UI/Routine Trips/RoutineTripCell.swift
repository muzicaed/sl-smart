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
    tripTitleLabel.text = routineTrip.title! //+ " [\(String(routineTrip.score))]"
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
        let diffMin = Int((second.departureDateTime.timeIntervalSince1970 - NSDate().timeIntervalSince1970) / 60)
        nextInAboutLabel.text = "Nästa: \(diffMin) min"
        nextInAboutLabel.hidden = false
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
        if count > 5 { return }
        let data = TripHelper.friendlyLineData(segment)
        
        let iconView = UIImageView(image: TripIcons.icons[data.icon]!)
        iconView.frame.size = CGSizeMake(15, 15)
        iconView.center = CGPointMake(23 / 2, 9)
        
        let label = UILabel()
        label.text = data.short
        label.textAlignment = NSTextAlignment.Center
        label.font = UIFont.systemFontOfSize(7)
        label.textColor = UIColor.darkGrayColor()
        label.sizeToFit()
        label.frame.size.width = 25
        label.center = CGPointMake((23 / 2), 22)
        label.lineBreakMode = .ByTruncatingTail
        
        let wrapperView = UIView(
          frame:CGRect(
            origin: CGPointMake(0, 0),
            size: CGSizeMake(23, 30)))
        wrapperView.frame.origin = CGPointMake((23 * CGFloat(count)), 0)
        wrapperView.clipsToBounds = false
        
        wrapperView.addSubview(iconView)
        wrapperView.addSubview(label)
        
        if segment.rtuMessages != nil {
          let warnIconView = UIImageView(image: TripIcons.icons["WARNING-ICON"]!)
          warnIconView.frame.size = CGSizeMake(10, 10)
          warnIconView.center = CGPointMake((23 / 2) + 5, 4)
          wrapperView.insertSubview(warnIconView, aboveSubview: iconView)
        }
        
        iconAreaView.addSubview(wrapperView)
        count++
      }
    }
  }
  
  
  /**
   * Sets no trips found UI
   */
  private func setNoTripsUI() {
    iconAreaView.subviews.forEach({ $0.removeFromSuperview() })
    
    departureTimeLabel.text = "00:00"
    arrivalTimeLabel.text = "00:00"
    inAboutLabel.text = ""
    
    tripDurationLabel.text = "Hittade ingen resa..."
  }
}