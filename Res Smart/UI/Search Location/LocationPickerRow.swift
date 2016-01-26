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
  @IBOutlet var switchImage: UIView!
  
  @IBOutlet var originView: UIView!
  @IBOutlet var destinationView: UIView!
  
  var delegate: PickLocationResponder?
  
  /**
   * Prepares the tap gestures.
   */
  func prepareGestures() {
    let originTouchGesture = UILongPressGestureRecognizer(
      target: self, action: Selector("onOriginTouchStart:"))
    originTouchGesture.minimumPressDuration = 0.001
    originStackView.gestureRecognizers = [originTouchGesture]
    
    let destinationTouchGesture = UILongPressGestureRecognizer(
      target: self, action: Selector("onDestinationTouchStart:"))
    destinationTouchGesture.minimumPressDuration = 0.001
    destinationStackView.gestureRecognizers = [destinationTouchGesture]
    
    let switchGesture = UITapGestureRecognizer(
      target: self, action: Selector("onSwitchTap"))
    switchImage.gestureRecognizers = [switchGesture]
  }
  
  /**
   * On origin touch
   */
  func onOriginTouchStart(gesture: UILongPressGestureRecognizer) {
    if gesture.state == .Began {
      originView.backgroundColor = StyleHelper.sharedInstance.mainGreenLight
    } else if gesture.state == .Ended {
      UIView.animateWithDuration(0.2, animations: {
        self.originView.backgroundColor = UIColor.clearColor()
      })
      originView.backgroundColor = UIColor.clearColor()
      if let del = delegate {
        del.pickLocation(true)
      }
    }
  }
  
  /**
   * On destination touch
   */
  func onDestinationTouchStart(gesture: UILongPressGestureRecognizer) {
    if gesture.state == .Began {
      destinationView.backgroundColor = StyleHelper.sharedInstance.mainGreenLight
    } else if gesture.state == .Ended {
      UIView.animateWithDuration(0.2, animations: {
        self.destinationView.backgroundColor = UIColor.clearColor()
      })
      if let del = delegate {
        del.pickLocation(false)
      }
    }
  }
  
  /**
   * On destination tap
   */
  func onSwitchTap() {
    if let del = delegate {
      UIView.animateWithDuration(0.15, animations: {
        self.originLabel.alpha = 0
        self.destinationLabel.alpha = 0
        }, completion: { _ in
          del.switchTapped()
          
          UIView.animateWithDuration(0.25, animations: {
            self.originLabel.alpha = 1
            self.destinationLabel.alpha = 1
          })
      })
    }
  }
}