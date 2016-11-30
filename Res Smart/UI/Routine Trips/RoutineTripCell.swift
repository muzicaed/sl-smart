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
  
  @IBOutlet weak var wrapperView: UIView?
  
  let normalColor = UIColor(red: 63/255, green: 73/255, blue: 62/255, alpha: 0.6)
  
  /**
   * Populate cell data based on passed RoutineTrip
   */
  func setupData(_ routineTrip: RoutineTrip, isBest: Bool) {
    var title = routineTrip.title!
    if routineTrip.isSmartSuggestion {
      title = "\(routineTrip.criterions.origin!.cleanName) - \(routineTrip.criterions.dest!.cleanName)"
      title += NSLocalizedString(" (Vana)", comment: "")
    }
    
    tripTitleLabel.text = title
    tripTitleLabel.accessibilityTraits |= UIAccessibilityTraitButton
    tripTitleLabel.accessibilityLabel = title
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
    
    if let wrapper = wrapperView {
      wrapper.accessibilityLabel = "\(routineTrip.title!), Från: \(originLabel.text!), Till: \(destinationLabel.text!). Tryck för tider och mer info."
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
    nextInAboutLabel.isHidden = true
    arrowLabel.isHidden = false
    if let first = trip.tripSegments.first, let last = trip.tripSegments.last  {
      departureTimeLabel.text = DateUtils.dateAsTimeString(first.departureDateTime)
      departureTimeLabel.accessibilityLabel = "Avgår: " + departureTimeLabel.text!
      arrivalTimeLabel.text = DateUtils.dateAsTimeString(last.arrivalDateTime)
      arrivalTimeLabel.accessibilityLabel = "Framme: " + arrivalTimeLabel.text!
      
      if DateUtils.dateAsDateString(first.departureDateTime) != DateUtils.dateAsDateString(Date()) {
        inAboutLabel.text = "Imorgon"
      } else {
        inAboutLabel.text = DateUtils.createAboutTimeText(
          first.departureDateTime, isWalk: first.type == TripType.Walk)
      }
      
      tripDurationLabel.text = DateUtils.createTripDurationString(trip.durationMin)
      handleInvalidTrips(trip)
      createTripSegmentIcons(trip)
    }
    
    if let first = trip.tripSegments.first, let second = secondTrip?.tripSegments.first {
      createNextInAboutText(first, second: second)
    }
  }
  
  /**
   * Creates text for next in about text label
   */
  fileprivate func createNextInAboutText(_ first : TripSegment, second: TripSegment) {
    let depTimeInterval = first.departureDateTime.timeIntervalSinceNow
    if depTimeInterval < (60 * 11) {
      let diffMin = Int(ceil(((second.departureDateTime.timeIntervalSince1970 - Date().timeIntervalSince1970) / 60)) + 0.5)
      if diffMin <= 60 {
        nextInAboutLabel.text = String(format: NSLocalizedString("Nästa: %d min", comment: ""), diffMin)
        nextInAboutLabel.isHidden = false
      }
    }
  }
  
  /**
   * Handles invalid trips (Canccelled or not reachable)
   */
  fileprivate func handleInvalidTrips(_ trip: Trip) {
    inAboutLabel.textColor = UIColor.black
    if !trip.isValid {
      let validTuple = trip.checkInvalidSegments()
      inAboutLabel.textColor = StyleHelper.sharedInstance.warningColor
      inAboutLabel.text = (validTuple.isCancelled) ? "Inställd" : "Kort bytestid"
      tripDurationLabel.text = ""
    } else if inAboutLabel.text == "Redan avgått" {
      inAboutLabel.textColor = StyleHelper.sharedInstance.warningColor
    }
  }
  
  /**
   * Creates trip type icon per segment.
   */
  fileprivate func createTripSegmentIcons(_ trip: Trip) {
    iconAreaView.subviews.forEach({ $0.removeFromSuperview() })
    var count = 0
    for (idx, segment) in trip.tripSegments.enumerated() {
      if segment.type != .Walk || (segment.type == .Walk && (segment.distance! > 30 || idx == 0) ) {
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
    inAboutLabel.text = ""
    
    tripDurationLabel.text = NSLocalizedString("Hittade ingen resa...", comment: "")
  }
}
