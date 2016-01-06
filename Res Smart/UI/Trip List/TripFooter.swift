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
  
  func displaySpinner(alpha: CGFloat) {
    self.spinnerView.alpha = alpha
    self.titleLabel.alpha = 1.0 - (alpha * 1.5)
    if spinnerView.alpha >= 1.0 {
      spinnerView.startAnimating()
    }
  }
  
  func displayLabel() {
    self.titleLabel.alpha = 1
    self.spinnerView.alpha = 0
    spinnerView.stopAnimating()
  }
}