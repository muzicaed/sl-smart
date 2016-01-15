//
//  TripFooter.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-27.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit

class TripFooter: UITableViewHeaderFooterView {
  
  @IBOutlet weak var spinnerView: UIActivityIndicatorView!
  
  func displaySpinner(alpha: CGFloat) {
    self.spinnerView.alpha = alpha
    if spinnerView.alpha >= 1.0 {
      spinnerView.startAnimating()
    }
  }
  
  func hideSpinner() {
    self.spinnerView.alpha = 0
    spinnerView.stopAnimating()
  }
}