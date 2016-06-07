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
    originLabel.accessibilityLabel = "Från \(originLabel.text!)"
    destinationLabel.text = trip.tripSegments.last?.destination.cleanName
    destinationLabel.accessibilityLabel = "vid \(destinationLabel.text!)"
    if trip.tripSegments.count > 0 {
      let trip = trip
      departureTimeLabel.textColor = StyleHelper.sharedInstance.mainGreen
      departureTimeLabel.text = DateUtils.dateAsTimeString(
        trip.tripSegments.first!.departureDateTime)
      departureTimeLabel.accessibilityLabel = "Avgår \(departureTimeLabel.text!)"
      
      arrivalTimeLabel.textColor = StyleHelper.sharedInstance.mainGreen
      arrivalTimeLabel.text = DateUtils.dateAsTimeString(
        trip.tripSegments.last!.arrivalDateTime)
      arrivalTimeLabel.accessibilityLabel = "Framme \(arrivalTimeLabel.text!)"
      
      inAboutLabel.text = DateUtils.createAboutTimeText(
        trip.tripSegments.first!.departureDateTime,
        isWalk: trip.tripSegments.first!.type == TripType.Walk)
      
      if trip.isValid {
        tripDurationLabel.text = DateUtils.createTripDurationString(trip.durationMin)
      }
      
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
        iconView.frame.size = CGSizeMake(22, 23)
        iconView.center = CGPointMake(22 / 2, 5)
        
        let label = UILabel()
        label.text = "\u{200A}\(data.short)\u{200A}\u{200C}"
        label.textAlignment = NSTextAlignment.Center
        label.font = UIFont.boldSystemFontOfSize(9)
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        label.textColor = UIColor.whiteColor()
        label.backgroundColor = data.color
        label.frame.size.width = 22
        label.frame.size.height = 12
        label.center = CGPointMake((22 / 2), 22)
        label.isAccessibilityElement = false
        
        let wrapperView = UIView(
          frame:CGRect(
            origin: CGPointMake(0, 0),
            size: CGSizeMake(22, 39)))
        wrapperView.frame.origin = CGPointMake((26 * CGFloat(count)), 5)
        wrapperView.clipsToBounds = false
        
        wrapperView.addSubview(iconView)
        wrapperView.addSubview(label)
        
        if segment.rtuMessages != nil {
          var warnIconView = UIImageView(image: TripIcons.icons["INFO-ICON"]!)
          if segment.isWarning {
            warnIconView = UIImageView(image: TripIcons.icons["WARNING-ICON"]!)
          }
          warnIconView.frame.size = CGSizeMake(10, 10)
          warnIconView.center = CGPointMake((22 / 2) + 10, -5)
          warnIconView.alpha = 0.9
          wrapperView.insertSubview(warnIconView, aboveSubview: iconView)
        }
        
        iconAreaView.addSubview(wrapperView)
        count += 1
      }
      if trip.hasAnyRealtime() {
        createRealtimeIcon(trip, count: count)
      }
    }
  }
  
  /**
   * Creates realtime icon
   */
  private func createRealtimeIcon(trip: Trip, count: Int) {
    let iconView = UIImageView(image: UIImage(named: "RealtimeIcon"))
    iconView.frame.size = CGSizeMake(15, 15)
    iconView.center = CGPointMake(22 / 2, 15)
    iconView.frame.origin = CGPointMake((26 * CGFloat(count)), 5)

    iconAreaView.addSubview(iconView)
  }
}