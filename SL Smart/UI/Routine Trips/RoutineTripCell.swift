//
//  RoutineTripCell.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-20.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit

class RoutineTripCell: UICollectionViewCell {
  
  @IBOutlet weak var tripTitleLabel: UILabel!
  @IBOutlet weak var originLabel: UILabel!
  @IBOutlet weak var destinationLabel: UILabel!
  @IBOutlet weak var departureTimeLabel: UILabel!
  @IBOutlet weak var arrivalTimeLabel: UILabel!
  @IBOutlet weak var iconAreaView: UIView!
  @IBOutlet weak var tripDurationLabel: UILabel!
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
    layer.borderColor = UIColor.whiteColor().CGColor
    layer.cornerRadius = 6
    layer.borderWidth = 4
  }
  
  /**
   * Populate cell data based on passed RoutineTrip
   */
  func setupData(routineTrip: RoutineTrip) {
    tripTitleLabel.text = routineTrip.title!
    originLabel.text = routineTrip.origin?.name
    destinationLabel.text = routineTrip.destination?.name
    if routineTrip.trip.tripSegments.count > 0 {
      let bestTrip = routineTrip.trip
      departureTimeLabel.text = Utils.dateAsTimeString(
        bestTrip.tripSegments.first!.departureDateTime)
      arrivalTimeLabel.text = Utils.dateAsTimeString(
        bestTrip.tripSegments.last!.arrivalDateTime)
      inAboutLabel.text = createAboutTimeText(
        bestTrip.tripSegments.first!.departureDateTime)
      tripDurationLabel.text = "Restid: \(bestTrip.durationMin) min"
      createTripSegmentIcons(bestTrip)
    }
  }
  
  // MARK: Private methods
  
  /**
  * Creates an "(om xx min)" for depature time.
  */
  private func createAboutTimeText(departure: NSDate) -> String {
    let diffMin = (departure.timeIntervalSince1970 - NSDate().timeIntervalSince1970) / 60
    if diffMin < 16 {
      return "❨om \(Int(diffMin)) min❩"
    }
    
    return ""
  }
  
  /**
   * Creates trip type icon per segment.
   */
  private func createTripSegmentIcons(trip: Trip) {
    iconAreaView.subviews.forEach({ $0.removeFromSuperview() })
    
    for (index, segment) in trip.tripSegments.enumerate() {
      if index > 5 { return }
      let data = TripHelper.friendlyLineData(segment.type, lineNumber: segment.lineNumber)
      
      let iconView = UIImageView(image: UIImage(named: data.icon))
      iconView.frame.size = CGSizeMake(15, 15)
      iconView.center = CGPointMake(23 / 2, 9)
      
      let label = UILabel()
      label.text = data.short
      label.textAlignment = NSTextAlignment.Center
      label.font = UIFont.systemFontOfSize(6.5)
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