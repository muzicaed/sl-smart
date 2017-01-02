//
//  CurrentTripCell.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-08-09.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit
import ResStockholmApiKit

class CurrentTripCell: UICollectionViewCell {
  
  
  @IBOutlet weak var arrowLabel: UILabel!
  
  @IBOutlet weak var tripTitleLabel: UILabel!
  @IBOutlet weak var originLabel: UILabel!
  @IBOutlet weak var destinationLabel: UILabel!
  @IBOutlet weak var departureTimeLabel: UILabel!
  @IBOutlet weak var arrivalTimeLabel: UILabel!
  @IBOutlet weak var iconAreaView: UIView!
  @IBOutlet weak var tripDurationLabel: UILabel!
  
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
    layer.shadowOffset = CGSize(width: 1, height: 1)
    layer.shadowRadius = 1.5
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOpacity = 0.10
    layer.cornerRadius = 4.0
    clipsToBounds = false
  }
  
  /**
   * Populate cell data based on passed RoutineTrip
   */
  func setupData(_ trip: Trip) {
    if let first = trip.tripSegments.first, let last = trip.tripSegments.last  {
      originLabel.text = first.origin.cleanName
      destinationLabel.text = last.destination.cleanName
      departureTimeLabel.text = DateUtils.dateAsTimeString(first.departureDateTime)
      departureTimeLabel.accessibilityLabel = "Avgår: " + departureTimeLabel.text!
      arrivalTimeLabel.text = DateUtils.dateAsTimeString(last.arrivalDateTime)
      arrivalTimeLabel.accessibilityLabel = "Framme: " + arrivalTimeLabel.text!
      
      tripDurationLabel.text = DateUtils.createTripDurationString(trip.durationMin)
      createTripSegmentIcons(trip)
    }
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
  
  fileprivate func setupTripData(_ trip: Trip, secondTrip: Trip?) {
    if let first = trip.tripSegments.first, let last = trip.tripSegments.last  {
      departureTimeLabel.text = DateUtils.dateAsTimeString(first.departureDateTime)
      departureTimeLabel.accessibilityLabel = "Avgår: " + departureTimeLabel.text!
      arrivalTimeLabel.text = DateUtils.dateAsTimeString(last.arrivalDateTime)
      arrivalTimeLabel.accessibilityLabel = "Framme: " + arrivalTimeLabel.text!
      
      tripDurationLabel.text = DateUtils.createTripDurationString(trip.durationMin)
      createTripSegmentIcons(trip)
    }
  }
  
  /**
   * Creates trip type icon per segment.
   */
  fileprivate func createTripSegmentIcons(_ trip: Trip) {
    iconAreaView.subviews.forEach({ $0.removeFromSuperview() })
    var count = 0
    for (_, segment) in trip.tripSegments.enumerated() {
      if segment.type != .Walk || (segment.type == .Walk && segment.distance! > 30) {
        if count >= 6 { return }
        let data = TripHelper.friendlyLineData(segment)
        
        let iconView = UIImageView(image: TripIcons.icons[data.icon]!)
        iconView.frame.size = CGSize(width: 22, height: 22)
        iconView.center = CGPoint(x: 22 / 2, y: 3)
        
        let label = UILabel()
        label.text = "\u{200A}\(data.short)\u{200A}\u{200C}"
        label.accessibilityLabel = "Steg \(count + 1): " + data.long
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont.boldSystemFont(ofSize: 9)
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        label.textColor = UIColor.white
        label.backgroundColor = data.color
        label.frame.size.width = 22
        label.frame.size.height = 12
        label.center = CGPoint(x: (22 / 2), y: 20)
        
        let wrapperView = UIView(
          frame:CGRect(
            origin: CGPoint(x: 0, y: 0),
            size: CGSize(width: 22, height: 36)))
        wrapperView.frame.origin = CGPoint(x: (26 * CGFloat(count)), y: 3)
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
        }
        
        iconAreaView.addSubview(wrapperView)
        count += 1
      }
    }
  }
  
  /**
   * Sets no trips found UI
   */
  fileprivate func setNoTripsUI() {
    iconAreaView.subviews.forEach({ $0.removeFromSuperview() })
    departureTimeLabel.text = "--:--"
    arrivalTimeLabel.text = "--:--"
    
    tripDurationLabel.text = NSLocalizedString("Hittade ingen resa...", comment: "")
  }
}
