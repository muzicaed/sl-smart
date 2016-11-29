//
//  LoadMoreCell.swift
//  SL Smart
//
//  Created by Mikael Hellman on 2015-11-27.
//  Copyright © 2015 Mikael Hellman. All rights reserved.
//

import Foundation
import UIKit

class LoadMoreCell: UITableViewCell {
  
  @IBOutlet weak var spinnerView: UIActivityIndicatorView!
  @IBOutlet weak var loadButton: UIButton!
  
  func displaySpinner(_ alpha: CGFloat) {
    spinnerView.alpha = alpha
    loadButton.alpha = 1.0 - (alpha)
    if spinnerView.alpha >= 1.0 {
      spinnerView.startAnimating()
    }
  }
  
  func hideSpinner() {
    spinnerView.alpha = 0
    loadButton.alpha = 1
    spinnerView.stopAnimating()
  }
}
