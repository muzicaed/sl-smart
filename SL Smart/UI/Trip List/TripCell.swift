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

class TripCell: UICollectionViewCell {
  
  @IBOutlet weak var originLabel: UILabel!
  @IBOutlet weak var destinationLabel: UILabel!
  @IBOutlet weak var departureTimeLabel: UILabel!
  @IBOutlet weak var arrivalTimeLabel: UILabel!
  @IBOutlet weak var iconAreaView: UIView!
  @IBOutlet weak var tripDurationLabel: UILabel!
  @IBOutlet weak var leftBarView: UIView!
  @IBOutlet weak var inAboutLabel: UILabel!
  
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
    layer.cornerRadius = 4.0
    clipsToBounds = false
  }
  
  /**
   * Populate cell data based on passed RoutineTrip
   */
  func setupData(trip: Trip) {
    print("Setup data")
    originLabel.text = trip.tripSegments.first?.origin.cleanName
    destinationLabel.text = trip.tripSegments.last?.destination.cleanName
    if trip.tripSegments.count > 0 {
      let trip = trip
      departureTimeLabel.text = DateUtils.dateAsTimeString(
        trip.tripSegments.first!.departureDateTime)
      arrivalTimeLabel.text = DateUtils.dateAsTimeString(
        trip.tripSegments.last!.arrivalDateTime)
      inAboutLabel.text = createAboutTimeText(
        trip.tripSegments.first!.departureDateTime)
      
      tripDurationLabel.text = DateUtils.createTripDurationString(trip.durationMin)
      
      createTripSegmentIcons(trip)
    }
  }
  
  // MARK: Private methods
  
  /**
  * Creates an "(om xx min)" for depature time.
  */
  private func createAboutTimeText(departure: NSDate) -> String {
    let diffMin = Int((departure.timeIntervalSince1970 - NSDate().timeIntervalSince1970) / 60)
    if diffMin <= 30 {
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
        
        wrapperView.addSubview(iconView)
        wrapperView.addSubview(label)
        wrapperView.clipsToBounds = false
        iconAreaView.addSubview(wrapperView)
        count++
      }
    }
  }
}