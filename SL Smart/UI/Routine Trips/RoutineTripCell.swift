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
    layer.borderColor = UIColor.whiteColor().CGColor
    layer.cornerRadius = 6
    layer.borderWidth = 4
  }
  
  /**
   * Populate cell data based on passed RoutineTrip
   */
  func setupData(routineTrip: RoutineTrip) {
    tripTitleLabel.text = routineTrip.title! + " [\(String(routineTrip.score))]"
    originLabel.text = routineTrip.origin?.cleanName
    destinationLabel.text = routineTrip.destination?.cleanName
    
    if let trip = routineTrip.trips.first {
      setupTripData(trip)
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
  
  private func setupTripData(trip: Trip) {
    if let first = trip.tripSegments.first, last = trip.tripSegments.last  {
      departureTimeLabel.text = Utils.dateAsTimeString(first.departureDateTime)
      arrivalTimeLabel.text = Utils.dateAsTimeString(last.arrivalDateTime)
      inAboutLabel.text = createAboutTimeText(first.departureDateTime)
      
      tripDurationLabel.text = "Restid: \(trip.durationMin) min"
      
      createTripSegmentIcons(trip)
    }
  }
  
  /**
   * Creates an "(om xx min)" for depature time.
   */
  private func createAboutTimeText(departure: NSDate) -> String {
    let diffMin = Int((departure.timeIntervalSince1970 - NSDate().timeIntervalSince1970) / 60)
    if diffMin < 16 {
      let diffMinStr = (diffMin + 1 <= 1) ? " Avgår nu" : " om \(diffMin + 1) min"
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