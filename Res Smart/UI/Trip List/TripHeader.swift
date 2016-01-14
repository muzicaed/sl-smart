//
//  TripHeader.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-28.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit

class TripHeader: UICollectionReusableView {
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var spinner: UIActivityIndicatorView!
  
  func displaySpinner(alpha: CGFloat) {
    self.spinner.alpha = alpha + 0.2
    if spinner.alpha >= 1.0 {
      spinner.startAnimating()
    }
  }
  
  func hideSpinner() {
    self.spinner.alpha = 0.0
    spinner.stopAnimating()
  }
}
