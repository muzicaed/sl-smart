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
  @IBOutlet weak var leftBarView: UIView!
  @IBOutlet weak var inAboutLabel: UILabel!
  
  /**
   * Populate cell data based on passed RoutineTrip
   */
  func setupData(trip: Trip, originalDate: NSDate) {
    originLabel.text = trip.tripSegments.first?.origin.cleanName
    destinationLabel.text = trip.tripSegments.last?.destination.cleanName
    if trip.tripSegments.count > 0 {
      let trip = trip
      departureTimeLabel.text = Utils.dateAsTimeString(
        trip.tripSegments.first!.departureDateTime)
      arrivalTimeLabel.text = Utils.dateAsTimeString(
        trip.tripSegments.last!.arrivalDateTime)
      inAboutLabel.text = createAboutTimeText(
        trip.tripSegments.first!.departureDateTime)
      
      tripDurationLabel.text = "Restid: \(trip.durationMin) min"
      
      createTripSegmentIcons(trip)
      checkInPast(trip.tripSegments.first!.departureDateTime, originalDate: originalDate)
    }
  }
  
  // MARK: Private methods
  
  /**
  * Checks if trip is in the past, and marks it.
  */
  private func checkInPast(date: NSDate, originalDate: NSDate) {
    if date.timeIntervalSinceDate(originalDate) < 0 {
      self.alpha = 0.6
      leftBarView.backgroundColor = UIColor.lightGrayColor()
      departureTimeLabel.textColor = UIColor.darkGrayColor()
      arrivalTimeLabel.textColor = UIColor.darkGrayColor()
      tripDurationLabel.text = "Redan avgått"
    }
  }
  
  /**
   * Creates an "(om xx min)" for depature time.
   */
  private func createAboutTimeText(departure: NSDate) -> String {
    let diffMin = Int((departure.timeIntervalSince1970 - NSDate().timeIntervalSince1970) / 60)
    if diffMin < 16 {
      let diffMinStr = (diffMin + 1 <= 1) ? "Avgår nu" : "om \(diffMin + 1) min"
      return diffMinStr
    }
    
    return ""
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
        wrapperView.frame.origin = CGPointMake((23 * CGFloat(count)), 0)
        
        wrapperView.addSubview(iconView)
        wrapperView.addSubview(label)
        wrapperView.clipsToBounds = false
        iconAreaView.addSubview(wrapperView)
        count++
      }
    }
  }
}