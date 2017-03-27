//
//  LocationPickerRow.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-12-13.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit
import ResStockholmApiKit

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
      target: self, action: #selector(onOriginTouchStart(_:)))
    originTouchGesture.minimumPressDuration = 0.001
    originStackView.gestureRecognizers = [originTouchGesture]
    
    let destinationTouchGesture = UILongPressGestureRecognizer(
      target: self, action: #selector(onDestinationTouchStart(_:)))
    destinationTouchGesture.minimumPressDuration = 0.001
    destinationStackView.gestureRecognizers = [destinationTouchGesture]
    
    let switchGesture = UITapGestureRecognizer(
      target: self, action: #selector(onSwitchTap))
    switchImage.gestureRecognizers = [switchGesture]
    switchImage.isAccessibilityElement = true
    switchImage.accessibilityTraits |= UIAccessibilityTraitButton
    switchImage.accessibilityLabel = "Byt plats på från och till".localized
    
    originView.accessibilityTraits |= UIAccessibilityTraitButton
    destinationView.accessibilityTraits |= UIAccessibilityTraitButton
  }
  
  /**
   * On origin touch
   */
  func onOriginTouchStart(_ gesture: UILongPressGestureRecognizer) {
    if gesture.state == .began {
      originView.backgroundColor = StyleHelper.sharedInstance.highlight
    } else if gesture.state == .ended {
      UIView.animate(withDuration: 0.2, animations: {
        self.originView.backgroundColor = UIColor.clear
      })
      originView.backgroundColor = UIColor.clear
      if let del = delegate {
        del.pickLocation(true)
      }
    }
  }
  
  /**
   * On destination touch
   */
  func onDestinationTouchStart(_ gesture: UILongPressGestureRecognizer) {
    if gesture.state == .began {
      destinationView.backgroundColor = StyleHelper.sharedInstance.highlight
    } else if gesture.state == .ended {
      UIView.animate(withDuration: 0.2, animations: {
        self.destinationView.backgroundColor = UIColor.clear
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
      UIView.animate(withDuration: 0.15, animations: {
        self.originLabel.alpha = 0
        self.destinationLabel.alpha = 0
        }, completion: { _ in
          del.switchTapped()
          
          UIView.animate(withDuration: 0.25, animations: {
            self.originLabel.alpha = 1
            self.destinationLabel.alpha = 1
          })
      })
    }
  }
  
  /**
   * Sets the text for origin label.
   */
  func setOriginLabelLocation(_ location: Location?) {
    if let loc = location {
      originLabel.text = loc.name
      originView.accessibilityLabel = "\("Från".localized): \(loc.name)"
    } else {
      originLabel.text = "(Välj station eller adress)".localized
      originView.accessibilityLabel = "\("Från".localized): \("(Välj station eller adress)".localized)"
    }
  }
  
  /**
   * Sets the text for origin label.
   */
  func setDestinationLabelLocation(_ location: Location?) {
    if let loc = location {
      destinationLabel.text = loc.name
      destinationView.accessibilityLabel = "\("Till".localized): \(loc.name)"
    } else {
      destinationLabel.text = "(Välj station eller adress)".localized
      destinationView.accessibilityLabel = "\("Till".localized): \("(Välj station eller adress)".localized)"
    }
  }
}
