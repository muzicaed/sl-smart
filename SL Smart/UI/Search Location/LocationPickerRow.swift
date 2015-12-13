//
//  LocationPickerRow.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-12-13.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit

class LocationPickerRow: UITableViewCell {

  @IBOutlet var originLabel: UILabel!
  @IBOutlet var destinationLabel: UILabel!
  @IBOutlet var originStackView: UIStackView!
  @IBOutlet var destinationStackView: UIStackView!
  
  var delegate: PickLocationResponder?
  
  /**
   * Prepares the tap gestures.
   */
  func prepareGestures() {
    let originGesture = UITapGestureRecognizer(target: self, action: Selector("onOriginTap"))
    originStackView.gestureRecognizers = [originGesture]
    let destinationGesture = UITapGestureRecognizer(target: self, action: Selector("onDestinationTap"))
    destinationStackView.gestureRecognizers = [destinationGesture]
  }
  
  /**
   * On origin tap
   */
  func onOriginTap() {
    if let del = delegate {
      del.pickLocation(true)
    }
  }
  
  /**
   * On destination tap
   */
  func onDestinationTap() {
    if let del = delegate {
      del.pickLocation(false)
    }
  }
}