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
    layer.shadowOffset = CGSizeMake(1, 1)
    layer.shadowRadius = 1.5
    layer.shadowColor = UIColor.blackColor().CGColor
    layer.shadowOpacity = 0.10
    layer.cornerRadius = 4.0
    clipsToBounds = false
  }
  
  /**
   * Populate cell data based on passed RoutineTrip
   */
  func setupData(segment: TripSegment, isOrigin: Bool) {
    UIView.animateWithDuration(0.4) { 
      self.loadingSpinner.alpha = 0.0
      self.contentStackView.alpha = 1.0
    }
    if segment.type == .Walk {
      setupWalkData(segment)
    } else if isOrigin {
      setupOriginData(segment)
      return
    }
    setupDestinationData(segment)
  }
  
  // MARK: Private
  
  /**
   * Setup change row for origin.
   */
  private func setupOriginData(segment: TripSegment) {
  }
  
  /**
   * Setup change row for destination.
   */
  private func setupDestinationData(segment: TripSegment) {
  }
  
  /**
   * Setup change row for walk.
   */
  private func setupWalkData(segment: TripSegment) {
  }
}