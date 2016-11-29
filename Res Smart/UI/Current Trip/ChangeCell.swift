//
//  ChangeCell.swift
//  Res Smart
//
//  Created by Mikael Hellman on 2016-08-09.
//  Copyright © 2016 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit
import ResStockholmApiKit

class ChangeCell: UICollectionViewCell {
  
  @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
  @IBOutlet weak var contentStackView: UIStackView!
  @IBOutlet weak var nextActionLabel: UILabel!
  @IBOutlet weak var line1Label: UILabel!
  @IBOutlet weak var line2Label: UILabel!
  
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
  func setupData(_ segment: TripSegment, isOrigin: Bool) {
    if segment.type == .Walk {
      setupWalkData(segment)
    } else if isOrigin {
      setupOriginData(segment)
    } else {
      setupDestinationData(segment)
    }
    UIView.animate(withDuration: 0.4, animations: {
      self.loadingSpinner.alpha = 0.0
      self.contentStackView.alpha = 1.0
    }) 
  }
  
  // MARK: Private
  
  /**
   * Setup change row for origin.
   */
  fileprivate func setupOriginData(_ segment: TripSegment) {
    let segmentData = TripHelper.friendlyLineData(segment)
    let inAbout = DateUtils.createAboutTimeText(segment.departureDateTime, isWalk: false)
    let departureTime = DateUtils.dateAsTimeString(segment.departureDateTime)
    nextActionLabel.text = "Ta \(segmentData.long) från \(segment.origin.cleanName)"
    line1Label.text = "Mot \(segment.directionText!)"
    line2Label.text = "Avgår kl. \(departureTime) (\(inAbout))"
  }
  
  /**
   * Setup change row for destination.
   */
  fileprivate func setupDestinationData(_ segment: TripSegment) {
    let segmentData = TripHelper.friendlyLineData(segment)
    let inAbout = DateUtils.createAboutTimeText(segment.arrivalDateTime, isWalk: false)
    let arrivalTime = DateUtils.dateAsTimeString(segment.arrivalDateTime)
    nextActionLabel.text = "Åk till \(segment.destination.cleanName)"
    line1Label.text = "\(segmentData.long) mot \(segment.directionText!)"
    // Station count...
    line2Label.text = "x stationer kvar, framme kl. \(arrivalTime) (\(inAbout))"
  }
  
  /**
   * Setup change row for walk.
   */
  fileprivate func setupWalkData(_ segment: TripSegment) {
    /*
    let segmentData = TripHelper.friendlyLineData(segment)
    let inAbout = DateUtils.createAboutTimeText(segment.departureDateTime, isWalk: false)
    let departureTime = DateUtils.dateAsTimeString(segment.departureDateTime)
    nextActionLabel.text = "Gå till \(segment.destination.cleanName)"
    line1Label.text = "Ca. \(segment.distance!)"
    // Station count...
    line2Label.text = "Du behöver vara framme kl. \(departureTime) (\(inAbout))"
     */
  }
}
