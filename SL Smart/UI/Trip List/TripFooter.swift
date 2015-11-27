//
//  TripFooter.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-27.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit

class TripFooter: UICollectionReusableView {
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var spinnerView: UIActivityIndicatorView!
  
  func displaySpinner() {
    UIView.animateWithDuration(0.4, animations: {
      self.titleLabel.alpha = 0
      self.spinnerView.alpha = 1
    })
    
    spinnerView.startAnimating()
  }
  
  func displayLabel() {
    self.titleLabel.alpha = 1
    self.spinnerView.alpha = 0
  }
}